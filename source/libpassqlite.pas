(******************************************************************************)
(*                                libPasSQLite                                *)
(*               object pascal wrapper around SQLLite library                 *)
(*                        https://github.com/curl/curl                        *)
(*                                                                            *)
(* Copyright (c) 2020                                       Ivan Semenkov     *)
(* https://github.com/isemenkov/libpassqlite                ivan@semenkov.pro *)
(*                                                          Ukraine           *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the GNU General Public License as published by the Free *)
(* Software Foundation; either version 3 of the License.                      *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License for *)
(* more details.                                                              *)
(*                                                                            *)
(* A copy  of the  GNU General Public License is available  on the World Wide *)
(* Web at <http://www.gnu.org/copyleft/gpl.html>. You  can also obtain  it by *)
(* writing to the Free Software Foundation, Inc., 51  Franklin Street - Fifth *)
(* Floor, Boston, MA 02110-1335, USA.                                         *)
(*                                                                            *)
(******************************************************************************)
unit libpassqlite;

{$mode objfpc}{$H+}

interface

uses 
  SysUtils;

{$IFDEF FPC}
  {$PACKRECORDS C}
{$ENDIF}
  
const
  {$IFDEF WINDOWS}
    sqlite3_lib = 'sqlite3.dll';
  {$ENDIF}
  {$IFDEF UNIX}
    sqlite3_lib = 'sqlite3.so';
  {$ENDIF}
  {$IFDEF DARWIN}
    sqlite3_lib = 'libsqlite3.dylib';
  {$ENDIF}

type
  PPChar = ^PChar;
  sqlite3_int64 = type Int64;
  sqlite3_uint64 = type QWord;

  sqlite3_callback = function(pArg : Pointer; nCol : Integer; azVals : PPChar;
    azCols : PPChar) : Integer of object;

  { Each open SQLite database is represented by a pointer to an instance of the 
    opaque structure named "sqlite3". It is useful to think of an sqlite3 
    pointer as an object. }
  psqlite3 = ^sqlite3;
  sqlite3 = record
    
  end;
 
  { Many SQLite functions return an integer result code from the set shown here 
   in order to indicate success or failure. }
  const
    SQLITE_OK         { Successful result }                            = 0;
    SQLITE_ERROR      { Generic error }                                = 1;
    SQLITE_INTERNAL   { Internal logic error in SQLite }               = 2;
    SQLITE_PERM       { Access permission denied }                     = 3;
    SQLITE_ABORT      { Callback routine requested an abort }          = 4;
    SQLITE_BUSY       { The database file is locked }                  = 5;
    SQLITE_LOCKED     { A table in the database is locked }            = 6;
    SQLITE_NOMEM      { A malloc() failed }                            = 7;
    SQLITE_READONLY   { Attempt to write a readonly database }         = 8;
    SQLITE_INTERRUPT  { Operation terminated by sqlite3_interrupt() }  = 9;
    SQLITE_IOERR      { Some kind of disk I/O error occurred }         = 10;
    SQLITE_CORRUPT    { The database disk image is malformed }         = 11;
    SQLITE_NOTFOUND   { Unknown opcode in sqlite3_file_control() }     = 12;
    SQLITE_FULL       { Insertion failed because database is full }    = 13;
    SQLITE_CANTOPEN   { Unable to open the database file }             = 14;
    SQLITE_PROTOCOL   { Database lock protocol error }                 = 15;
    SQLITE_EMPTY      { Internal use only }                            = 16;
    SQLITE_SCHEMA     { The database schema changed }                  = 17;
    SQLITE_TOOBIG     { String or BLOB exceeds size limit }            = 18;
    SQLITE_CONSTRAINT { Abort due to constraint violation }            = 19;
    SQLITE_MISMATCH   { Data type mismatch }                           = 20;
    SQLITE_MISUSE     { Library used incorrectly }                     = 21;
    SQLITE_NOLFS      { Uses OS features not supported on host }       = 22;
    SQLITE_AUTH       { Authorization denied }                         = 23;
    SQLITE_FORMAT     { Not used }                                     = 24;
    SQLITE_RANGE      { 2nd parameter to sqlite3_bind out of range }   = 25;
    SQLITE_NOTADB     { File opened that is not a database file }      = 26;
    SQLITE_NOTICE     { Notifications from sqlite3_log() }             = 27;
    SQLITE_WARNING    { Warnings from sqlite3_log() }                  = 28;
    SQLITE_ROW        { sqlite3_step() has another row ready }         = 100;
    SQLITE_DONE       { sqlite3_step() has finished executing }        = 101;

    { The SQLITE_ERROR_MISSING_COLLSEQ result code means that an SQL statement 
      could not be prepared because a collating sequence named in that SQL 
      statement could not be located.

      Sometimes when this error code is encountered, the sqlite3_prepare_v2() 
      routine will convert the error into SQLITE_ERROR_RETRY and try again to 
      prepare the SQL statement using a different query plan that does not 
      require the use of the unknown collating sequence. }
    SQLITE_ERROR_MISSING_COLLSEQ                  = SQLITE_ERROR or (1 shl 8);

    { The SQLITE_ERROR_RETRY is used internally to provoke sqlite3_prepare_v2() 
      (or one of its sibling routines for creating prepared statements) to try 
      again to prepare a statement that failed with an error on the previous 
      attempt. }
    SQLITE_ERROR_RETRY                           = SQLITE_ERROR or (2 shl 8);

    { The SQLITE_ERROR_SNAPSHOT result code might be returned when attempting to 
      start a read transaction on an historical version of the database by using 
      the sqlite3_snapshot_open() interface. If the historical snapshot is no 
      longer available, then the read transaction will fail with the 
      SQLITE_ERROR_SNAPSHOT. This error code is only possible if SQLite is 
      compiled with -DSQLITE_ENABLE_SNAPSHOT. } 
    SQLITE_ERROR_SNAPSHOT                        = SQLITE_ERROR or (3 shl 8);

    { The SQLITE_IOERR_READ error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to read 
      from a file on disk. This error might result from a hardware malfunction 
      or because a filesystem came unmounted while the file was open. }
    SQLITE_IOERR_READ                            = SQLITE_IOERR or (1 shl 8);

    { The SQLITE_IOERR_SHORT_READ error code is an extended error code for 
      SQLITE_IOERR indicating that a read attempt in the VFS layer was unable to 
      obtain as many bytes as was requested. This might be due to a truncated 
      file. }
    SQLITE_IOERR_SHORT_READ                      = SQLITE_IOERR or (2 shl 8);

    { The SQLITE_IOERR_WRITE error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      write into a file on disk. This error might result from a hardware 
      malfunction or because a filesystem came unmounted while the file was 
      open. This error should not occur if the filesystem is full as there is a 
      separate error code (SQLITE_FULL) for that purpose. }
    SQLITE_IOERR_WRITE                           = SQLITE_IOERR or (3 shl 8);

    { The SQLITE_IOERR_FSYNC error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      flush previously written content out of OS and/or disk-control buffers and 
      into persistent storage. In other words, this code indicates a problem 
      with the fsync() system call in unix or the FlushFileBuffers() system call 
      in windows. }
    SQLITE_IOERR_FSYNC                           = SQLITE_IOERR or (4 shl 8);

    { The SQLITE_IOERR_DIR_FSYNC error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      invoke fsync() on a directory. The unix VFS attempts to fsync() 
      directories after creating or deleting certain files to ensure that those 
      files will still appear in the filesystem following a power loss or system 
      crash. This error code indicates a problem attempting to perform that 
      fsync(). }
    SQLITE_IOERR_DIR_FSYNC                       = SQLITE_IOERR or (5 shl 8);

    { The SQLITE_IOERR_TRUNCATE error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      truncate a file to a smaller size.  }
    SQLITE_IOERR_TRUNCATE                        = SQLITE_IOERR or (6 shl 8);

    { The SQLITE_IOERR_FSTAT error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      invoke fstat() (or the equivalent) on a file in order to determine 
      information such as the file size or access permissions. }
    SQLITE_IOERR_FSTAT                           = SQLITE_IOERR or (7 shl 8);

    { The SQLITE_IOERR_UNLOCK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within xUnlock method on the 
      sqlite3_io_methods object. }
    SQLITE_IOERR_UNLOCK                          = SQLITE_IOERR or (8 shl 8);

    { The SQLITE_IOERR_UNLOCK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within xLock method on the 
      sqlite3_io_methods object while trying to obtain a read lock. }
    SQLITE_IOERR_RDLOCK                          = SQLITE_IOERR or (9 shl 8);

    { The SQLITE_IOERR_UNLOCK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within xDelete method on the 
      sqlite3_vfs object. }
    SQLITE_IOERR_DELETE                          = SQLITE_IOERR or (10 shl 8);

    { The SQLITE_IOERR_BLOCKED error code is no longer used. }
    SQLITE_IOERR_BLOCKED                         = SQLITE_IOERR or (11 shl 8);

    { The SQLITE_IOERR_NOMEM error code is sometimes returned by the VFS layer 
      to indicate that an operation could not be completed due to the inability 
      to allocate sufficient memory. This error code is normally converted into 
      SQLITE_NOMEM by the higher layers of SQLite before being returned to the 
      application. }
    SQLITE_IOERR_NOMEM                           = SQLITE_IOERR or (12 shl 8);

    { The SQLITE_IOERR_ACCESS error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xAccess method on the 
      sqlite3_vfs object. }
    SQLITE_IOERR_ACCESS                          = SQLITE_IOERR or (13 shl 8); 

    { The SQLITE_IOERR_CHECKRESERVEDLOCK error code is an extended error code 
      for SQLITE_IOERR indicating an I/O error within the xCheckReservedLock 
      method on the sqlite3_io_methods object.  }
    SQLITE_IOERR_CHECKRESERVEDLOCK               = SQLITE_IOERR or (14 shl 8);

    { The SQLITE_IOERR_LOCK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the advisory file locking logic. 
      Usually an SQLITE_IOERR_LOCK error indicates a problem obtaining a PENDING 
      lock. However it can also indicate miscellaneous locking errors on some of 
      the specialized VFSes used on Macs. }
    SQLITE_IOERR_LOCK                            = SQLITE_IOERR or (15 shl 8);

    { The SQLITE_IOERR_ACCESS error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xClose method on the 
      sqlite3_io_methods object. }
    SQLITE_IOERR_CLOSE                           = SQLITE_IOERR or (16 shl 8);

    { The SQLITE_IOERR_DIR_CLOSE error code is no longer used. }
    SQLITE_IOERR_DIR_CLOSE                       = SQLITE_IOERR or (17 shl 8);

    { The SQLITE_IOERR_SHMOPEN error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xShmMap method on the 
      sqlite3_io_methods object while trying to open a new shared memory 
      segment. }
    SQLITE_IOERR_SHMOPEN                         = SQLITE_IOERR or (18 shl 8);

    { The SQLITE_IOERR_SHMSIZE error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xShmMap method on the 
      sqlite3_io_methods object while trying to enlarge a "shm" file as part of 
      WAL mode transaction processing. This error may indicate that the 
      underlying filesystem volume is out of space. }
    SQLITE_IOERR_SHMSIZE                         = SQLITE_IOERR or (19 shl 8);

    { The SQLITE_IOERR_SHMLOCK error code is no longer used. }
    SQLITE_IOERR_SHMLOCK                         = SQLITE_IOERR or (20 shl 8);

    { The SQLITE_IOERR_SHMMAP error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xShmMap method on the 
      sqlite3_io_methods object while trying to map a shared memory segment into 
      the process address space. }
    SQLITE_IOERR_SHMMAP                          = SQLITE_IOERR or (21 shl 8);

    { The SQLITE_IOERR_SEEK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xRead or xWrite methods on 
      the sqlite3_io_methods object while trying to seek a file descriptor to 
      the beginning point of the file where the read or write is to occur. }
    SQLITE_IOERR_SEEK                            = SQLITE_IOERR or (22 shl 8);

    { The SQLITE_IOERR_DELETE_NOENT error code is an extended error code for 
      SQLITE_IOERR indicating that the xDelete method on the sqlite3_vfs object 
      failed because the file being deleted does not exist. }
    SQLITE_IOERR_DELETE_NOENT                    = SQLITE_IOERR or (23 shl 8);

    { The SQLITE_IOERR_MMAP error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xFetch or xUnfetch methods 
      on the sqlite3_io_methods object while trying to map or unmap part of the 
      database file into the process address space. }
    SQLITE_IOERR_MMAP                            = SQLITE_IOERR or (24 shl 8);

    { The SQLITE_IOERR_GETTEMPPATH error code is an extended error code for 
      SQLITE_IOERR indicating that the VFS is unable to determine a suitable 
      directory in which to place temporary files. }
    SQLITE_IOERR_GETTEMPPATH                     = SQLITE_IOERR or (25 shl 8);

    { The SQLITE_IOERR_CONVPATH error code is an extended error code for 
      SQLITE_IOERR used only by Cygwin VFS and indicating that the 
      cygwin_conv_path() system call failed. See also: 
      SQLITE_CANTOPEN_CONVPATH. }
    SQLITE_IOERR_CONVPATH                        = SQLITE_IOERR or (26 shl 8);

    SQLITE_IOERR_VNODE                           = SQLITE_IOERR or (27 shl 8);
    SQLITE_IOERR_AUTH                            = SQLITE_IOERR or (28 shl 8);
    SQLITE_IOERR_BEGIN_ATOMIC                    = SQLITE_IOERR or (29 shl 8);
    SQLITE_IOERR_COMMIT_ATOMIC                   = SQLITE_IOERR or (30 shl 8);
    SQLITE_IOERR_ROLLBACK_ATOMIC                 = SQLITE_IOERR or (31 shl 8);
    SQLITE_IOERR_DATA                            = SQLITE_IOERR or (32 shl 8);

    { The SQLITE_LOCKED_SHAREDCACHE error code is an extended error code for 
      SQLITE_LOCKED indicating that the locking conflict has occurred due to 
      contention with a different database connection that happens to hold a 
      shared cache with the database connection to which the error was returned. 
      For example, if the other database connection is holding an exclusive lock 
      on the database, then the database connection that receives this error 
      will be unable to read or write any part of the database file unless it 
      has the read_uncommitted pragma enabled.

      The SQLITE_LOCKED_SHARECACHE error code works very much like the 
      SQLITE_BUSY error code except that SQLITE_LOCKED_SHARECACHE is for 
      separate database connections that share a cache whereas SQLITE_BUSY is 
      for the much more common case of separate database connections that do not 
      share the same cache. Also, the sqlite3_busy_handler() and 
      sqlite3_busy_timeout() interfaces do not help in resolving 
      SQLITE_LOCKED_SHAREDCACHE conflicts. }
    SQLITE_LOCKED_SHAREDCACHE                   = SQLITE_LOCKED or (1 shl 8);

    { The SQLITE_LOCKED_VTAB result code is not used by the SQLite core, but it 
      is available for use by extensions. Virtual table implementations can 
      return this result code to indicate that they cannot complete the current 
      operation because of locks held by other threads or processes.

      The R-Tree extension returns this result code when an attempt is made to 
      update the R-Tree while another prepared statement is actively reading the 
      R-Tree. The update cannot proceed because any change to an R-Tree might 
      involve reshuffling and rebalancing of nodes, which would disrupt read 
      cursors, causing some rows to be repeated and other rows to be omitted. }
    SQLITE_LOCKED_VTAB                          = SQLITE_LOCKED or (2 shl 8);

    { The SQLITE_BUSY_RECOVERY error code is an extended error code for 
      SQLITE_BUSY that indicates that an operation could not continue because 
      another process is busy recovering a WAL mode database file following a 
      crash. The SQLITE_BUSY_RECOVERY error code only occurs on WAL mode 
      databases. }
    SQLITE_BUSY_RECOVERY                          = SQLITE_BUSY or (1 shl 8);

    { The SQLITE_BUSY_SNAPSHOT error code is an extended error code for 
      SQLITE_BUSY that occurs on WAL mode databases when a database connection 
      tries to promote a read transaction into a write transaction but finds 
      that another database connection has already written to the database and 
      thus invalidated prior reads.

      The following scenario illustrates how an SQLITE_BUSY_SNAPSHOT error might 
      arise:
        Process A starts a read transaction on the database and does one or more 
          SELECT statement. Process A keeps the transaction open.
        Process B updates the database, changing values previous read by process 
          A.
        Process A now tries to write to the database. But process A's view of 
          the database content is now obsolete because process B has modified 
          the database file after process A read from it. Hence process A gets  
          an SQLITE_BUSY_SNAPSHOT error. }
    SQLITE_BUSY_SNAPSHOT                          = SQLITE_BUSY or (2 shl 8);

    SQLITE_BUSY_TIMEOUT                           = SQLITE_BUSY or (3 shl 8); 

    { The SQLITE_CANTOPEN_NOTEMPDIR error code is no longer used. }
    SQLITE_CANTOPEN_NOTEMPDIR                 = SQLITE_CANTOPEN or (1 shl 8);

    { The SQLITE_CANTOPEN_ISDIR error code is an extended error code for 
      SQLITE_CANTOPEN indicating that a file open operation failed because the 
      file is really a directory. }
    SQLITE_CANTOPEN_ISDIR                     = SQLITE_CANTOPEN or (2 shl 8);

    { The SQLITE_CANTOPEN_FULLPATH error code is an extended error code for 
      SQLITE_CANTOPEN indicating that a file open operation failed because the 
      operating system was unable to convert the filename into a full pathname.}
    SQLITE_CANTOPEN_FULLPATH                  = SQLITE_CANTOPEN or (3 shl 8);

    { The SQLITE_CANTOPEN_CONVPATH error code is an extended error code for 
      SQLITE_CANTOPEN used only by Cygwin VFS and indicating that the 
      cygwin_conv_path() system call failed while trying to open a file. See 
      also: SQLITE_IOERR_CONVPATH }
    SQLITE_CANTOPEN_CONVPATH                  = SQLITE_CANTOPEN or (4 shl 8);

    { The SQLITE_CANTOPEN_DIRTYWAL result code is not used at this time. }
    SQLITE_CANTOPEN_DIRTYWAL                  = SQLITE_CANTOPEN or (5 shl 8); 

    SQLITE_CANTOPEN_SYMLINK                   = SQLITE_CANTOPEN or (6 shl 8);

    { The SQLITE_CORRUPT_VTAB error code is an extended error code for 
      SQLITE_CORRUPT used by virtual tables. A virtual table might return 
      SQLITE_CORRUPT_VTAB to indicate that content in the virtual table is 
      corrupt. }
    SQLITE_CORRUPT_VTAB                        = SQLITE_CORRUPT or (1 shl 8);

    { The SQLITE_CORRUPT_SEQUENCE result code means that the schema of the 
      sqlite_sequence table is corrupt. The sqlite_sequence table is used to 
      help implement the AUTOINCREMENT feature. }
    SQLITE_CORRUPT_SEQUENCE                    = SQLITE_CORRUPT or (2 shl 8);

    SQLITE_CORRUPT_INDEX                       = SQLITE_CORRUPT or (3 shl 8);

    { The SQLITE_READONLY_RECOVERY error code is an extended error code for 
      SQLITE_READONLY. The SQLITE_READONLY_RECOVERY error code indicates that a 
      WAL mode database cannot be opened because the database file needs to be 
      recovered and recovery requires write access but only read access is 
      available. }
    SQLITE_READONLY_RECOVERY                  = SQLITE_READONLY or (1 shl 8);

    { The SQLITE_READONLY_CANTLOCK error code is an extended error code for 
      SQLITE_READONLY. The SQLITE_READONLY_CANTLOCK error code indicates that 
      SQLite is unable to obtain a read lock on a WAL mode database because the 
      shared-memory file associated with that database is read-only. }
    SQLITE_READONLY_CANTLOCK                  = SQLITE_READONLY or (2 shl 8);

    { The SQLITE_READONLY_ROLLBACK error code is an extended error code for 
      SQLITE_READONLY. The SQLITE_READONLY_ROLLBACK error code indicates that a 
      database cannot be opened because it has a hot journal that needs to be 
      rolled back but cannot because the database is readonly. }
    SQLITE_READONLY_ROLLBACK                  = SQLITE_READONLY or (3 shl 8);

    { The SQLITE_READONLY_DBMOVED error code is an extended error code for 
      SQLITE_READONLY. The SQLITE_READONLY_DBMOVED error code indicates that a 
      database cannot be modified because the database file has been moved since 
      it was opened, and so any attempt to modify the database might result in 
      database corruption if the processes crashes because the rollback journal 
      would not be correctly named. }
    SQLITE_READONLY_DBMOVED                   = SQLITE_READONLY or (4 shl 8);

    { The SQLITE_READONLY_CANTINIT result code originates in the xShmMap method 
      of a VFS to indicate that the shared memory region used by WAL mode exists 
      buts its content is unreliable and unusable by the current process since 
      the current process does not have write permission on the shared memory 
      region. (The shared memory region for WAL mode is normally a file with a 
      "-wal" suffix that is mmapped into the process space. If the current 
      process does not have write permission on that file, then it cannot write 
      into shared memory.)

      Higher level logic within SQLite will normally intercept the error code 
      and create a temporary in-memory shared memory region so that the current 
      process can at least read the content of the database. This result code 
      should not reach the application interface layer. }
    SQLITE_READONLY_CANTINIT                  = SQLITE_READONLY or (5 shl 8);

    { The SQLITE_READONLY_DIRECTORY result code indicates that the database is 
      read-only because process does not have permission to create a journal 
      file in the same directory as the database and the creation of a journal 
      file is a prerequisite for writing. }
    SQLITE_READONLY_DIRECTORY                 = SQLITE_READONLY or (6 shl 8);

    { The SQLITE_ABORT_ROLLBACK error code is an extended error code for 
      SQLITE_ABORT indicating that an SQL statement aborted because the 
      transaction that was active when the SQL statement first started was 
      rolled back. Pending write operations always fail with this error when a 
      rollback occurs. A ROLLBACK will cause a pending read operation to fail 
      only if the schema was changed within the transaction being rolled back. }
    SQLITE_ABORT_ROLLBACK                        = SQLITE_ABORT or (2 shl 8);

    { The SQLITE_CONSTRAINT_CHECK error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a CHECK constraint failed. }
    SQLITE_CONSTRAINT_CHECK                 = SQLITE_CONSTRAINT or (1 shl 8);

    { The SQLITE_CONSTRAINT_COMMITHOOK error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a commit hook callback returned non-zero 
      that thus caused the SQL statement to be rolled back. }
    SQLITE_CONSTRAINT_COMMITHOOK            = SQLITE_CONSTRAINT or (2 shl 8);

    { The SQLITE_CONSTRAINT_FOREIGNKEY error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a foreign key constraint failed. }
    SQLITE_CONSTRAINT_FOREIGNKEY            = SQLITE_CONSTRAINT or (3 shl 8);

    { The SQLITE_CONSTRAINT_FUNCTION error code is not currently used by the 
      SQLite core. However, this error code is available for use by extension 
      functions. }
    SQLITE_CONSTRAINT_FUNCTION              = SQLITE_CONSTRAINT or (4 shl 8);

    { The SQLITE_CONSTRAINT_NOTNULL error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a NOT NULL constraint failed. }
    SQLITE_CONSTRAINT_NOTNULL               = SQLITE_CONSTRAINT or (5 shl 8);

    { The SQLITE_CONSTRAINT_PRIMARYKEY error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a PRIMARY KEY constraint failed. }
    SQLITE_CONSTRAINT_PRIMARYKEY            = SQLITE_CONSTRAINT or (6 shl 8);

    { The SQLITE_CONSTRAINT_TRIGGER error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a RAISE function within a trigger fired, 
      causing the SQL statement to abort. }
    SQLITE_CONSTRAINT_TRIGGER               = SQLITE_CONSTRAINT or (7 shl 8);

    { The SQLITE_CONSTRAINT_UNIQUE error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a UNIQUE constraint failed. }
    SQLITE_CONSTRAINT_UNIQUE                = SQLITE_CONSTRAINT or (8 shl 8);

    { The SQLITE_CONSTRAINT_VTAB error code is not currently used by the SQLite 
      core. However, this error code is available for use by application-defined 
      virtual tables. }
    SQLITE_CONSTRAINT_VTAB                  = SQLITE_CONSTRAINT or (9 shl 8);

    { The SQLITE_CONSTRAINT_ROWID error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a rowid is not unique. }
    SQLITE_CONSTRAINT_ROWID                 = SQLITE_CONSTRAINT or (10 shl 8);

    SQLITE_CONSTRAINT_PINNED                = SQLITE_CONSTRAINT or (11 shl 8);

    { The SQLITE_NOTICE_RECOVER_WAL result code is passed to the callback of 
      sqlite3_log() when a WAL mode database file is recovered. }
    SQLITE_NOTICE_RECOVER_WAL                   = SQLITE_NOTICE or (1 shl 8);

    { The SQLITE_NOTICE_RECOVER_ROLLBACK result code is passed to the callback 
      of sqlite3_log() when a hot journal is rolled back. }
    SQLITE_NOTICE_RECOVER_ROLLBACK              = SQLITE_NOTICE or (2 shl 8);

    { The SQLITE_WARNING_AUTOINDEX result code is passed to the callback of 
     sqlite3_log() whenever automatic indexing is used. This can serve as a 
     warning to application designers that the database might benefit from 
     additional indexes. }
    SQLITE_WARNING_AUTOINDEX                   = SQLITE_WARNING or (1 shl 8);

    SQLITE_AUTH_USER                           = SQLITE_AUTH or (1 shl 8);

    { The sqlite3_load_extension() interface loads an extension into a single 
      database connection. The default behavior is for that extension to be 
      automatically unloaded when the database connection closes. However, if 
      the extension entry point returns SQLITE_OK_LOAD_PERMANENTLY instead of 
      SQLITE_OK, then the extension remains loaded into the process address 
      space after the database connection closes. In other words, the xDlClose 
      methods of the sqlite3_vfs object is not called for the extension when the 
      database connection closes.

      The SQLITE_OK_LOAD_PERMANENTLY return code is useful to loadable 
      extensions that register new VFSes, for example. }
    SQLITE_OK_LOAD_PERMANENTLY                      = SQLITE_OK or (1 shl 8);

    SQLITE_OK_SYMLINK                               = SQLITE_OK or (2 shl 8);

{ These interfaces provide the same information as the SQLITE_VERSION, 
  SQLITE_VERSION_NUMBER, and SQLITE_SOURCE_ID C preprocessor macros but are 
  associated with the library instead of the header file. Cautious programmers 
  might include assert() statements in their application to verify that values 
  returned by these interfaces match the macros in the header, and thus ensure 
  that the application is compiled with matching library and header files.
  
  The sqlite3_version[] string constant contains the text of SQLITE_VERSION 
  macro. The sqlite3_libversion() function returns a pointer to the to the 
  sqlite3_version[] string constant. The sqlite3_libversion() function is 
  provided for use in DLLs since DLL users usually do not have direct access to 
  string constants within the DLL. The sqlite3_libversion_number() function 
  returns an integer equal to SQLITE_VERSION_NUMBER. The sqlite3_sourceid() 
  function returns a pointer to a string constant whose value is the same as the 
  SQLITE_SOURCE_ID C preprocessor macro. Except if SQLite is built using an 
  edited copy of the amalgamation, then the last four characters of the hash 
  might be different from SQLITE_SOURCE_ID. }
function sqlite3_libversion : PChar; cdecl; external sqlite3_lib;
function sqlite3_sourceid : PChar; cdecl; external sqlite3_lib;
function sqlite3_libversion_number : Integer; cdecl; external sqlite3_lib;

{ The sqlite3_compileoption_used() function returns 0 or 1 indicating whether 
  the specified option was defined at compile time. The SQLITE_ prefix may be 
  omitted from the option name passed to sqlite3_compileoption_used().

  The sqlite3_compileoption_get() function allows iterating over the list of 
  options that were defined at compile time by returning the N-th compile time 
  option string. If N is out of range, sqlite3_compileoption_get() returns a 
  NULL pointer. The SQLITE_ prefix is omitted from any strings returned by 
  sqlite3_compileoption_get().

  Support for the diagnostic functions sqlite3_compileoption_used() and 
  sqlite3_compileoption_get() may be omitted by specifying the 
  SQLITE_OMIT_COMPILEOPTION_DIAGS option at compile time. }
function sqlite3_compileoption_used(const zOptName : PChar) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_compileoption_get(N : Integer) : PChar; cdecl; 
  external sqlite3_lib;

{ The sqlite3_threadsafe() function returns zero if and only if SQLite was 
  compiled with mutexing code omitted due to the SQLITE_THREADSAFE compile-time 
  option being set to 0.

  SQLite can be compiled with or without mutexes. When the SQLITE_THREADSAFE C 
  preprocessor macro is 1 or 2, mutexes are enabled and SQLite is threadsafe. 
  When the SQLITE_THREADSAFE macro is 0, the mutexes are omitted. Without the 
  mutexes, it is not safe to use SQLite concurrently from more than one thread.

  Enabling mutexes incurs a measurable performance penalty. So if speed is of 
  utmost importance, it makes sense to disable the mutexes. But for maximum 
  safety, mutexes should be enabled. The default behavior is for mutexes to be 
  enabled.

  This interface can be used by an application to make sure that the version of 
  SQLite that it is linking against was compiled with the desired setting of the 
  SQLITE_THREADSAFE macro.

  This interface only reports on the compile-time mutex setting of the 
  SQLITE_THREADSAFE flag. If SQLite is compiled with SQLITE_THREADSAFE=1 or =2 
  then mutexes are enabled by default but can be fully or partially disabled 
  using a call to sqlite3_config() with the verbs SQLITE_CONFIG_SINGLETHREAD, 
  SQLITE_CONFIG_MULTITHREAD, or SQLITE_CONFIG_SERIALIZED. The return value of 
  the sqlite3_threadsafe() function shows only the compile-time setting of 
  thread safety, not any run-time changes to that setting made by 
  sqlite3_config(). In other words, the return value from sqlite3_threadsafe() 
  is unchanged by calls to sqlite3_config(). }
function sqlite3_threadsafe : Integer; cdecl; external sqlite3_lib;

{ The sqlite3_close() and sqlite3_close_v2() routines are destructors for the 
  sqlite3 object. Calls to sqlite3_close() and sqlite3_close_v2() return 
  SQLITE_OK if the sqlite3 object is successfully destroyed and all associated 
  resources are deallocated.

  Ideally, applications should finalize all prepared statements, close all BLOB 
  handles, and finish all sqlite3_backup objects associated with the sqlite3 
  object prior to attempting to close the object. If the database connection is 
  associated with unfinalized prepared statements, BLOB handlers, and/or 
  unfinished sqlite3_backup objects then sqlite3_close() will leave the database 
  connection open and return SQLITE_BUSY. If sqlite3_close_v2() is called with 
  unfinalized prepared statements, unclosed BLOB handlers, and/or unfinished 
  sqlite3_backups, it returns SQLITE_OK regardless, but instead of deallocating 
  the database connection immediately, it marks the database connection as an 
  unusable "zombie" and makes arrangements to automatically deallocate the 
  database connection after all prepared statements are finalized, all BLOB 
  handles are closed, and all backups have finished. The sqlite3_close_v2() 
  interface is intended for use with host languages that are garbage collected, 
  and where the order in which destructors are called is arbitrary.

  If an sqlite3 object is destroyed while a transaction is open, the transaction 
  is automatically rolled back.

  The C parameter to sqlite3_close(C) and sqlite3_close_v2(C) must be either a 
  NULL pointer or an sqlite3 object pointer obtained from sqlite3_open(), 
  sqlite3_open16(), or sqlite3_open_v2(), and not previously closed. Calling 
  sqlite3_close() or sqlite3_close_v2() with a NULL pointer argument is a 
  harmless no-op. }
function sqlite3_close(handle : psqlite3) : Integer; cdecl; 
  external sqlite3_lib;
function sqlite3_close_v2(handle : psqlite3) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_exec() interface is a convenience wrapper around 
  sqlite3_prepare_v2(), sqlite3_step(), and sqlite3_finalize(), that allows an 
  application to run multiple statements of SQL without having to use a lot of 
  C code.

  The sqlite3_exec() interface runs zero or more UTF-8 encoded, 
  semicolon-separate SQL statements passed into its 2nd argument, in the 
  context of the database connection passed in as its 1st argument. If the 
  callback function of the 3rd argument to sqlite3_exec() is not NULL, then it 
  is invoked for each result row coming out of the evaluated SQL statements. The
  4th argument to sqlite3_exec() is relayed through to the 1st argument of each 
  callback invocation. If the callback pointer to sqlite3_exec() is NULL, then 
  no callback is ever invoked and result rows are ignored.

  If an error occurs while evaluating the SQL statements passed into 
  sqlite3_exec(), then execution of the current statement stops and subsequent 
  statements are skipped. If the 5th parameter to sqlite3_exec() is not NULL 
  then any error message is written into memory obtained from sqlite3_malloc() 
  and passed back through the 5th parameter. To avoid memory leaks, the 
  application should invoke sqlite3_free() on error message strings returned 
  through the 5th parameter of sqlite3_exec() after the error message string is 
  no longer needed. If the 5th parameter to sqlite3_exec() is not NULL and no 
  errors occur, then sqlite3_exec() sets the pointer in its 5th parameter to 
  NULL before returning.

  If an sqlite3_exec() callback returns non-zero, the sqlite3_exec() routine 
  returns SQLITE_ABORT without invoking the callback again and without running 
  any subsequent SQL statements.

  The 2nd argument to the sqlite3_exec() callback function is the number of 
  columns in the result. The 3rd argument to the sqlite3_exec() callback is an 
  array of pointers to strings obtained as if from sqlite3_column_text(), one 
  for each column. If an element of a result row is NULL then the corresponding 
  string pointer for the sqlite3_exec() callback is a NULL pointer. The 4th 
  argument to the sqlite3_exec() callback is an array of pointers to strings 
  where each entry represents the name of corresponding result column as 
  obtained from sqlite3_column_name().

  If the 2nd parameter to sqlite3_exec() is a NULL pointer, a pointer to an 
  empty string, or a pointer that contains only whitespace and/or SQL comments, 
  then no SQL statements are evaluated and the database is not changed. }
function sqlite3_exec(handle : psqlite3; const sql : PChar; callback : 
  sqlite3_callback; callback_arg : Pointer; errmsg : PPChar) : Integer; cdecl;
  external sqlite3_lib;




implementation

end.