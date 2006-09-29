/******************************************************************************
 * $Id$
 *
 * Visit http://transmission.m0k.org/cgi-bin/trac.cgi/ticket/127
 * and http://transmission.m0k.org/forum/viewtopic.php?p=3757#3757
 *
 * Sample usage: export HOME=/tmp/harddisk/tmp
 * transmissiond -p 65534 -w 60 -u 10 -i /opt/var/run/transmission.pid  \
 *                /tmp/harddisk/tmp/files.txt
 *
 * Always use full paths to facilitate reload.
 *
 * TODO: 
 *  config file 
 *  pidfile rewrite
 *  remove verbose
 *
 * Copyright (c) 2005-2006 Transmission authors and contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <signal.h>
#include <libgen.h>
#include <time.h>
#include <sys/stat.h>
#include <syslog.h>
#include <transmission.h>
#ifdef SYS_BEOS
#include <kernel/OS.h>
#define usleep snooze
#endif
#ifdef __GNUC__
#  define UNUSED __attribute__((unused))
#else
#  define UNUSED
#endif


#define USAGE \
"Usage: %s [options] files.txt [options]\n\n" \
"Options:\n" \
"  -h, --help           Print this help and exit\n" \
"  -v, --verbose <int>  Verbose level (0 to 2, default = 0)\n" \
"  -p, --port <int>     Port we should listen on (default = %d)\n" \
"  -u, --upload <int>   Maximum upload rate (-1 = no limit, default = 20)\n" \
"  -d, --download <int> Maximum download rate (-1 = no limit, default = -1)\n" \
"  -f, --finish <shell script> Command you wish to run on completion\n" \
"  -w, --watchdog <int> Watchdog interval in seconds (default = 600)\n" \
"  -i, --pidfile <path> PID file path \n" \
"Signals:\n"                                                            \
"\tHUP\treload files.txt and start/stop torrents\n"\
"\tUSR1\twrite .status files into torrent directories\n"   \
"\tUSR2\tlist active torrents\n"

static int           showHelp      = 0;
static int           verboseLevel  = 0;
static int           bindPort      = TR_DEFAULT_PORT;
static int           uploadLimit   = 20;
static int           downloadLimit = -1;
static char          * torrentPath = NULL;
static int           watchdogInterval = 600;
static volatile char mustDie       = 0;
static char          * pidfile = NULL;

static char          * finishCall   = NULL;
static tr_handle_t   * h;

static int  parseCommandLine ( int argc, char ** argv );

/* return number of items in array */
#define ALEN(a)                 (sizeof(a) / sizeof((a)[0]))

static void watchdog(tr_torrent_t *tor, void * data UNUSED)
{
  int result;

  if( tr_getFinished( tor ) )
    {
      result = system(finishCall);
    }  
}


/* Try for 5 seconds to notice the tracker that we are leaving */
static void stop(tr_torrent_t *tor, void * data UNUSED )
{
  int i;
  tr_stat_t    * s;
  tr_info_t * info =  tr_torrentInfo( tor );
  syslog( LOG_NOTICE, "Stopping torrent %s", info->torrent );
  tr_torrentStop( tor );
  for( i = 0; i < 10; i++ )
    {
      s = tr_torrentStat( tor );
      if( s->status & TR_STATUS_PAUSE )
        {
          /* The 'stopped' message was sent */
          break;
        }
      usleep( 500000 );
    }
  tr_torrentClose( h, tor );
  syslog( LOG_NOTICE, "All torrents stopped");
}

struct active_torrents_s
{
  char *torrent;
  char found;
};

#define TR_FACTIVE 0x80    /* Torrent should be active */


/* Check torrent if disposal is needed and clean active flag */
static void dispose(tr_torrent_t *tor, void * data )
{
  tr_info_t * info =  tr_torrentInfo( tor );
  if (info->flags & TR_FACTIVE)
    info->flags &= ~TR_FACTIVE;
  else
    stop(tor, data);
}

/* Check torrent by name provided and mark it as active */
static void is_active(tr_torrent_t *tor, void *data)
{
  struct active_torrents_s *a = (struct active_torrents_s *)data;
  tr_info_t * info =  tr_torrentInfo( tor );
  if ( 0 == strcmp(info->torrent, a->torrent))
    {
      a->found = 1;
      info->flags |= TR_FACTIVE; 
    }
}

static void reload()
{
  tr_torrent_t * tor;
  int error;
  FILE *stream;

  struct active_torrents_s active_torrents;

  syslog(LOG_DEBUG, "Reload called");

  /* open a file with a list of requested active torrents */
  if ( (stream = fopen(torrentPath, "r")) != NULL)
    {
      char fn[MAX_PATH_LENGTH];
      while (fgets(fn, MAX_PATH_LENGTH, stream) )
        {
          char *tr = fn;
          while(*tr) {
            if (*tr == '\n')
              { *tr = '\0';
                break;
              }
            tr++;
          }
          if ( tr == fn)
            continue;
          
          /* Is on the list of active_torrents ? */
          active_torrents.torrent = fn;
          active_torrents.found = 0;
          tr_torrentIterate(h, is_active, &active_torrents);
          if ( !active_torrents.found ) /* add new torrent */
            {
              if( !( tor = tr_torrentInit( h, fn, 0, &error ) ) )
                {
                  syslog(LOG_CRIT, "%.80s - %m", fn );
                }
              else
                {
                  tr_info_t * info =  tr_torrentInfo( tor );
                  char *folder = strdup(fn);
                  tr_torrentSetFolder( tor, dirname(folder));
                  free(folder);
                  tr_torrentStart( tor );
                  info->flags |= TR_FACTIVE; 
                }
            }
        }
      fclose(stream);
      /* Stop unwanted torrents which do not have active flag */
      tr_torrentIterate(h, dispose, NULL);
    }
  else
    syslog(LOG_ERR, "Active torrent file %s - %m", torrentPath);
}

/* Prepares status string up to 80 chars wide */
static char * status(tr_torrent_t *tor)
{
  static char string[80];
  int  chars = 0;

  tr_stat_t    * s = tr_torrentStat( tor );
  
  if( s->status & TR_STATUS_CHECK )
    {
      chars = snprintf( string, 80,
                        "Checking files... %.2f %%", 100.0 * s->progress );
    }
  else if( s->status & TR_STATUS_DOWNLOAD )
    {
      chars = snprintf( string, 80,
                        "Progress: %.2f %%, %d peer%s, dl from %d (%.2f KB/s), "
                        "ul to %d (%.2f KB/s)", 100.0 * s->progress,
                        s->peersTotal, ( s->peersTotal == 1 ) ? "" : "s",
                        s->peersUploading, s->rateDownload,
                        s->peersDownloading, s->rateUpload );
    }
  else if( s->status & TR_STATUS_SEED )
    {
      chars = snprintf( string, 80,
                        "Seeding, uploading to %d of %d peer(s), %.2f KB/s",
                        s->peersDownloading, s->peersTotal,
                        s->rateUpload );
    }
  else if( s->error & TR_ETRACKER )
    {
      snprintf( string, 80, "%s", s->trackerError );
    }
  else
    string[0] = '\0';

  return string;
}


static void write_info(tr_torrent_t *tor, void * data UNUSED )
{
  FILE *stream;
  char fn[MAX_PATH_LENGTH];
  
  snprintf(fn, MAX_PATH_LENGTH, "%s/.status", tr_torrentGetFolder(tor));
  stream = fopen(fn, "w");
  if ( stream )
    {
      fputs("STATUS='", stream);
      fputs(status(tor), stream);
      fputs("'\n", stream );
      fclose(stream);
    }
  else
    syslog(LOG_ERR, "%s - %m", fn);
}

/* List torrent name */
static void list(tr_torrent_t *tor, void * data UNUSED)
{
  tr_info_t * info =  tr_torrentInfo( tor );
  syslog(LOG_INFO, "'%s':%s", info->torrent, status(tor));
}


static void signalHandler( int signal )
{
  switch( signal )
    {
    case SIGINT:
    case SIGTERM:
      mustDie = 1;
      break;
    case SIGUSR1:
      tr_torrentIterate( h, write_info, NULL );
      break;
    case SIGUSR2:
      tr_torrentIterate( h, list, NULL );
      break;
    case SIGHUP:
      reload();
      break;
    default:
      break;
    }
}

static void setupsighandlers(void) {
  int sigs[] = {SIGHUP, SIGINT, SIGTERM, SIGUSR1, SIGUSR2};
  struct sigaction sa;
  unsigned int ii;

  bzero(&sa, sizeof(sa));
  sa.sa_handler = signalHandler;
  for(ii = 0; ii < ALEN(sigs); ii++)
    sigaction(sigs[ii], &sa, NULL);
}



static int writepidfile(int pid)
{
  FILE *f = fopen(pidfile, "w");
  if ( f != NULL)
    {
      fprintf(f, "%d\n", pid);
      fclose(f);
      return 0;
    }
  else
    syslog( LOG_CRIT, "%.80s - %m", pidfile );
  return -1;
}


int main( int argc, char ** argv )
{

  pid_t pid;
  char *cp;
  
  
  /* Get options */
  if( parseCommandLine( argc, argv ) )
    {
      printf( USAGE, argv[0], TR_DEFAULT_PORT );
      return 1;
    }
  
  if( showHelp )
    {
      printf( USAGE, argv[0], TR_DEFAULT_PORT );
      return 0;
    }
  
  if( verboseLevel < 0 )
    {
      verboseLevel = 0;
    }
  else if( verboseLevel > 9 )
    {
      verboseLevel = 9;
    }
  if( verboseLevel )
    {
      static char env[11];
      sprintf( env, "TR_DEBUG=%d", verboseLevel );
      putenv( env );
    }
  
  if( bindPort < 1 || bindPort > 65535 )
    {
      printf( "Invalid port '%d'\n", bindPort );
      return 1;
    }
  

  switch( fork())
    {
    case 0:
      break;
    case -1:
      syslog( LOG_CRIT, "fork - %m" );
      exit(1);
    default:
      exit(0);
    }
  
  /* child continues */
  
  setsid();    /* become session leader */
  pid = getpid();
  if ( chdir( "/" ) < 0)
    {
      syslog( LOG_CRIT, "chdir - %m" );
      exit( 1 );
    }

  /* We're not going to use stdin stdout or stderr from here on, so close
  ** them to save file descriptors.
  */

  fclose( stdin );
  fclose( stdout );
  fclose( stderr );  
  
  cp = strrchr( argv[0], '/' );
  if ( cp != (char*) 0 )
    ++cp;
  else
    cp = argv[0];
  
  openlog(cp, LOG_NDELAY|LOG_PID, LOG_USER);
  
  syslog(LOG_INFO,
         "Transmission daemon %s (%d) - http://transmission.m0k.org/\n\n",
         VERSION_STRING, VERSION_REVISION );
  
  
  if (pidfile != NULL)
    writepidfile(pid);
  
  
  /* Initialize libtransmission */
  h = tr_init();
  
  tr_setBindPort( h, bindPort );
  tr_setUploadLimit( h, uploadLimit );
  tr_setDownloadLimit( h, downloadLimit );
  
  setupsighandlers();
  reload();
  
  while( !mustDie )
    {
      float upload, download;
      sleep( watchdogInterval );
      tr_torrentIterate( h, watchdog, NULL );
      tr_torrentRates(h, &download, &upload);
      syslog(LOG_INFO, "%ld %d dl %.2f ul %.2f", time(NULL),
             tr_torrentCount( h ), download, upload);
    }
  
  tr_torrentIterate( h, stop, NULL );
  tr_close( h );
  
  if (pidfile != NULL)
    unlink(pidfile);
  
  syslog( LOG_NOTICE, "exiting" );
  closelog();
  
  return 0;
}



static int parseCommandLine( int argc, char ** argv )
{
    for( ;; )
    {
        static struct option long_options[] =
          { { "help",     no_argument,       NULL, 'h' },
            { "verbose",  required_argument, NULL, 'v' },
            { "port",     required_argument, NULL, 'p' },
            { "upload",   required_argument, NULL, 'u' },
            { "download", required_argument, NULL, 'd' },
            { "finish",   required_argument, NULL, 'f' },
            { "watchdog", required_argument, NULL, 'w' },
            { "pidfile",  required_argument, NULL, 'i' }, 
            { 0, 0, 0, 0} };

        int c, optind = 0;
        c = getopt_long( argc, argv, "hv:p:u:d:f:w:i:", long_options, &optind );
        if( c < 0 )
        {
            break;
        }
        switch( c )
          {
          case 'h':
            showHelp = 1;
            break;
          case 'v':
            verboseLevel = atoi( optarg );
            break;
          case 'p':
            bindPort = atoi( optarg );
            break;
          case 'u':
            uploadLimit = atoi( optarg );
            break;
          case 'd':
            downloadLimit = atoi( optarg );
            break;
          case 'f':
            finishCall = optarg;
            break;
          case 'w':
            watchdogInterval = atoi (optarg);
            break;
          case 'i':
            pidfile = optarg;
            break;
          default:
            return 1;
        }
    }

    if( optind > argc - 1  )
    {
        return !showHelp;
    }

    torrentPath = argv[optind];

    return 0;
}

