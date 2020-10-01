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

  SQLITE_AUTH_USER                              = SQLITE_AUTH or (1 shl 8);

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

  { Flags For File Open Operations

    These bit values are intended for use in the 3rd parameter to the 
    sqlite3_open_v2() interface and in the 4th parameter to the 
    sqlite3_vfs.xOpen method. }
  SQLITE_OPEN_READONLY      { Ok for sqlite3_open_v2() }            = $00000001;
  SQLITE_OPEN_READWRITE     { Ok for sqlite3_open_v2() }            = $00000002;
  SQLITE_OPEN_CREATE        { Ok for sqlite3_open_v2() }            = $00000004;
  SQLITE_OPEN_DELETEONCLOSE { VFS only }                            = $00000008;
  SQLITE_OPEN_EXCLUSIVE     { VFS only }                            = $00000010;
  SQLITE_OPEN_AUTOPROXY     { VFS only }                            = $00000020;
  SQLITE_OPEN_URI           { Ok for sqlite3_open_v2() }            = $00000040;
  SQLITE_OPEN_MEMORY        { Ok for sqlite3_open_v2() }            = $00000080;
  SQLITE_OPEN_MAIN_DB       { VFS only }                            = $00000100;
  SQLITE_OPEN_TEMP_DB       { VFS only }                            = $00000200;
  SQLITE_OPEN_TRANSIENT_DB  { VFS only }                            = $00000400;
  SQLITE_OPEN_MAIN_JOURNAL  { VFS only }                            = $00000800;
  SQLITE_OPEN_TEMP_JOURNAL  { VFS only }                            = $00001000;
  SQLITE_OPEN_SUBJOURNAL    { VFS only }                            = $00002000;
  SQLITE_OPEN_SUPER_JOURNAL { VFS only }                            = $00004000;
  SQLITE_OPEN_NOMUTEX       { Ok for sqlite3_open_v2() }            = $00008000;
  SQLITE_OPEN_FULLMUTEX     { Ok for sqlite3_open_v2() }            = $00010000;
  SQLITE_OPEN_SHAREDCACHE   { Ok for sqlite3_open_v2() }            = $00020000;
  SQLITE_OPEN_PRIVATECACHE  { Ok for sqlite3_open_v2() }            = $00040000;
  SQLITE_OPEN_WAL           { VFS only }                            = $00080000;
  SQLITE_OPEN_NOFOLLOW      { Ok for sqlite3_open_v2() }            = $01000000;

  { Legacy compatibility: }
  SQLITE_OPEN_MASTER_JOURNAL { VFS only }                           = $00004000;

  { The xDeviceCharacteristics method of the sqlite3_io_methods object returns 
    an integer which is a vector of these bit values expressing I/O 
    characteristics of the mass storage device that holds the file that the 
    sqlite3_io_methods refers to.

    The SQLITE_IOCAP_ATOMIC property means that all writes of any size are 
    atomic. The SQLITE_IOCAP_ATOMICnnn values mean that writes of blocks that 
    are nnn bytes in size and are aligned to an address which is an integer 
    multiple of nnn are atomic. The SQLITE_IOCAP_SAFE_APPEND value means that 
    when data is appended to a file, the data is appended first then the size of 
    the file is extended, never the other way around. The 
    SQLITE_IOCAP_SEQUENTIAL property means that information is written to disk 
    in the same order as calls to xWrite(). The SQLITE_IOCAP_POWERSAFE_OVERWRITE 
    property means that after reboot following a crash or power loss, the only 
    bytes in a file that were written at the application level might have 
    changed and that adjacent bytes, even bytes within the same sector are 
    guaranteed to be unchanged. The SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN flag 
    indicates that a file cannot be deleted when open. The 
    SQLITE_IOCAP_IMMUTABLE flag indicates that the file is on read-only media 
    and cannot be changed even by processes with elevated privileges.

    The SQLITE_IOCAP_BATCH_ATOMIC property means that the underlying filesystem 
    supports doing multiple write operations atomically when those write 
    operations are bracketed by SQLITE_FCNTL_BEGIN_ATOMIC_WRITE and 
    SQLITE_FCNTL_COMMIT_ATOMIC_WRITE. }
  SQLITE_IOCAP_ATOMIC                                               = $00000001;
  SQLITE_IOCAP_ATOMIC512                                            = $00000002;
  SQLITE_IOCAP_ATOMIC1K                                             = $00000004;
  SQLITE_IOCAP_ATOMIC2K                                             = $00000008;
  SQLITE_IOCAP_ATOMIC4K                                             = $00000010;
  SQLITE_IOCAP_ATOMIC8K                                             = $00000020;
  SQLITE_IOCAP_ATOMIC16K                                            = $00000040;
  SQLITE_IOCAP_ATOMIC32K                                            = $00000080;
  SQLITE_IOCAP_ATOMIC64K                                            = $00000100;
  SQLITE_IOCAP_SAFE_APPEND                                          = $00000200;
  SQLITE_IOCAP_SEQUENTIAL                                           = $00000400;
  SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN                                = $00000800;
  SQLITE_IOCAP_POWERSAFE_OVERWRITE                                  = $00001000;
  SQLITE_IOCAP_IMMUTABLE                                            = $00002000;
  SQLITE_IOCAP_BATCH_ATOMIC                                         = $00004000;

  { SQLite uses one of these integer values as the second argument to calls it 
    makes to the xLock() and xUnlock() methods of an sqlite3_io_methods object.}
  SQLITE_LOCK_NONE                                                  = 0;
  SQLITE_LOCK_SHARED                                                = 1;
  SQLITE_LOCK_RESERVED                                              = 2;
  SQLITE_LOCK_PENDING                                               = 3;
  SQLITE_LOCK_EXCLUSIVE                                             = 4;

  { When SQLite invokes the xSync() method of an sqlite3_io_methods object it 
    uses a combination of these integer values as the second argument.

    When the SQLITE_SYNC_DATAONLY flag is used, it means that the sync operation 
    only needs to flush data to mass storage. Inode information need not be 
    flushed. If the lower four bits of the flag equal SQLITE_SYNC_NORMAL, that 
    means to use normal fsync() semantics. If the lower four bits equal 
    SQLITE_SYNC_FULL, that means to use Mac OS X style fullsync instead of 
    fsync().

    Do not confuse the SQLITE_SYNC_NORMAL and SQLITE_SYNC_FULL flags with the 
    PRAGMA synchronous=NORMAL and PRAGMA synchronous=FULL settings. The 
    synchronous pragma determines when calls to the xSync VFS method occur and 
    applies uniformly across all platforms. The SQLITE_SYNC_NORMAL and 
    SQLITE_SYNC_FULL flags determine how energetic or rigorous or forceful the 
    sync operations are and only make a difference on Mac OSX for the default 
    SQLite code. (Third-party VFS implementations might also make the 
    distinction between SQLITE_SYNC_NORMAL and SQLITE_SYNC_FULL, but among the 
    operating systems natively supported by SQLite, only Mac OSX cares about the 
    difference.) }
  SQLITE_SYNC_NORMAL                                                = $00002;
  SQLITE_SYNC_FULL                                                  = $00003;
  SQLITE_SYNC_DATAONLY                                              = $00010;

  { Standard File Control Opcodes }

  { The SQLITE_FCNTL_LOCKSTATE opcode is used for debugging. This opcode causes 
    the xFileControl method to write the current state of the lock (one of 
    SQLITE_LOCK_NONE, SQLITE_LOCK_SHARED, SQLITE_LOCK_RESERVED, 
    SQLITE_LOCK_PENDING, or SQLITE_LOCK_EXCLUSIVE) into an integer that the pArg 
    argument points to. This capability is used during testing and is only 
    available when the SQLITE_TEST compile-time option is used. }
  SQLITE_FCNTL_LOCKSTATE                                            = 1;

  SQLITE_FCNTL_GET_LOCKPROXYFILE                                    = 2;
  SQLITE_FCNTL_SET_LOCKPROXYFILE                                    = 3;
  SQLITE_FCNTL_LAST_ERRNO                                           = 4;

  { The SQLITE_FCNTL_SIZE_HINT opcode is used by SQLite to give the VFS layer a 
    hint of how large the database file will grow to be during the current 
    transaction. This hint is not guaranteed to be accurate but it is often 
    close. The underlying VFS might choose to preallocate database file space 
    based on this hint in order to help writes to the database file run faster.}
  SQLITE_FCNTL_SIZE_HINT                                            = 5;

  { The SQLITE_FCNTL_CHUNK_SIZE opcode is used to request that the VFS extends 
    and truncates the database file in chunks of a size specified by the user. 
    The fourth argument to sqlite3_file_control() should point to an integer 
    (type int) containing the new chunk-size to use for the nominated database. 
    Allocating database file space in large chunks (say 1MB at a time), may 
    reduce file-system fragmentation and improve performance on some systems. }
  SQLITE_FCNTL_CHUNK_SIZE                                           = 6;

  { The SQLITE_FCNTL_FILE_POINTER opcode is used to obtain a pointer to the 
    sqlite3_file object associated with a particular database connection. See 
    also SQLITE_FCNTL_JOURNAL_POINTER. }
  SQLITE_FCNTL_FILE_POINTER                                         = 7;

  SQLITE_FCNTL_SYNC_OMITTED                                         = 8;

  { The SQLITE_FCNTL_WIN32_AV_RETRY opcode is used to configure automatic retry 
    counts and intervals for certain disk I/O operations for the windows VFS in 
    order to provide robustness in the presence of anti-virus programs. By 
    default, the windows VFS will retry file read, file write, and file delete 
    operations up to 10 times, with a delay of 25 milliseconds before the first 
    retry and with the delay increasing by an additional 25 milliseconds with 
    each subsequent retry. This opcode allows these two values (10 retries and 
    25 milliseconds of delay) to be adjusted. The values are changed for all 
    database connections within the same process. The argument is a pointer to 
    an array of two integers where the first integer is the new retry count and 
    the second integer is the delay. If either integer is negative, then the 
    setting is not changed but instead the prior value of that setting is 
    written into the array entry, allowing the current retry settings to be 
    interrogated. The zDbName parameter is ignored. }
  SQLITE_FCNTL_WIN32_AV_RETRY                                       = 9;

  { The SQLITE_FCNTL_PERSIST_WAL opcode is used to set or query the persistent. 
    Write Ahead Log setting. By default, the auxiliary write ahead log (WAL 
    file) and shared memory files used for transaction control are automatically 
    deleted when the latest connection to the database closes. Setting 
    persistent WAL mode causes those files to persist after close. Persisting 
    the files is useful when other processes that do not have write permission 
    on the directory containing the database file want to read the database 
    file, as the WAL and shared memory files must exist in order for the 
    database to be readable. The fourth parameter to sqlite3_file_control() for 
    this opcode should be a pointer to an integer. That integer is 0 to disable 
    persistent WAL mode or 1 to enable persistent WAL mode. If the integer is 
    -1, then it is overwritten with the current WAL persistence setting. }
  SQLITE_FCNTL_PERSIST_WAL                                          = 10;

  { The SQLITE_FCNTL_OVERWRITE opcode is invoked by SQLite after opening a write 
    transaction to indicate that, unless it is rolled back for some reason, the 
    entire database file will be overwritten by the current transaction. This is 
    used by VACUUM operations. }
  SQLITE_FCNTL_OVERWRITE                                            = 11;

  { The SQLITE_FCNTL_VFSNAME opcode can be used to obtain the names of all VFSes 
    in the VFS stack. The names are of all VFS shims and the final bottom-level 
    VFS are written into memory obtained from sqlite3_malloc() and the result is 
    stored in the char* variable that the fourth parameter of 
    sqlite3_file_control() points to. The caller is responsible for freeing the 
    memory when done. As with all file-control actions, there is no guarantee 
    that this will actually do anything. Callers should initialize the char* 
    variable to a NULL pointer in case this file-control is not implemented. 
    This file-control is intended for diagnostic use only. }
  SQLITE_FCNTL_VFSNAME                                              = 12;

  { The SQLITE_FCNTL_POWERSAFE_OVERWRITE opcode is used to set or query the 
    persistent "powersafe-overwrite" or "PSOW" setting. The PSOW setting 
    determines the SQLITE_IOCAP_POWERSAFE_OVERWRITE bit of the 
    xDeviceCharacteristics methods. The fourth parameter to 
    sqlite3_file_control() for this opcode should be a pointer to an integer. 
    That integer is 0 to disable zero-damage mode or 1 to enable zero-damage 
    mode. If the integer is -1, then it is overwritten with the current 
    zero-damage mode setting. }
  SQLITE_FCNTL_POWERSAFE_OVERWRITE                                  = 13;

  { Whenever a PRAGMA statement is parsed, an SQLITE_FCNTL_PRAGMA file control 
    is sent to the open sqlite3_file object corresponding to the database file 
    to which the pragma statement refers. The argument to the 
    SQLITE_FCNTL_PRAGMA file control is an array of pointers to strings (char**) 
    in which the second element of the array is the name of the pragma and the 
    third element is the argument to the pragma or NULL if the pragma has no 
    argument. The handler for an SQLITE_FCNTL_PRAGMA file control can optionally
    make the first element of the char** argument point to a string obtained 
    from sqlite3_mprintf() or the equivalent and that string will become the 
    result of the pragma or the error message if the pragma fails. If the 
    SQLITE_FCNTL_PRAGMA file control returns SQLITE_NOTFOUND, then normal PRAGMA 
    processing continues. If the SQLITE_FCNTL_PRAGMA file control returns 
    SQLITE_OK, then the parser assumes that the VFS has handled the PRAGMA 
    itself and the parser generates a no-op prepared statement if result string 
    is NULL, or that returns a copy of the result string if the string is 
    non-NULL. If the SQLITE_FCNTL_PRAGMA file control returns any result code 
    other than SQLITE_OK or SQLITE_NOTFOUND, that means that the VFS encountered 
    an error while handling the PRAGMA and the compilation of the PRAGMA fails 
    with an error. The SQLITE_FCNTL_PRAGMA file control occurs at the beginning 
    of pragma statement analysis and so it is able to override built-in PRAGMA 
    statements. }
  SQLITE_FCNTL_PRAGMA                                               = 14;

  { The SQLITE_FCNTL_BUSYHANDLER file-control may be invoked by SQLite on the 
    database file handle shortly after it is opened in order to provide a custom 
    VFS with access to the connection's busy-handler callback. The argument is 
    of type (void**) - an array of two (void *) values. The first (void *) 
    actually points to a function of type (int (*)(void *)). In order to invoke 
    the connection's busy-handler, this function should be invoked with the 
    second (void *) in the array as the only argument. If it returns non-zero, 
    then the operation should be retried. If it returns zero, the custom VFS 
    should abandon the current operation. }
  SQLITE_FCNTL_BUSYHANDLER                                          = 15;

  { Applications can invoke the SQLITE_FCNTL_TEMPFILENAME file-control to have 
    SQLite generate a temporary filename using the same algorithm that is 
    followed to generate temporary filenames for TEMP tables and other internal 
    uses. The argument should be a char** which will be filled with the filename 
    written into memory obtained from sqlite3_malloc(). The caller should invoke 
    sqlite3_free() on the result to avoid a memory leak. }
  SQLITE_FCNTL_TEMPFILENAME                                         = 16;

  { The SQLITE_FCNTL_MMAP_SIZE file control is used to query or set the maximum 
    number of bytes that will be used for memory-mapped I/O. The argument is a 
    pointer to a value of type sqlite3_int64 that is an advisory maximum number 
    of bytes in the file to memory map. The pointer is overwritten with the old 
    value. The limit is not changed if the value originally pointed to is 
    negative, and so the current limit can be queried by passing in a pointer to 
    a negative number. This file-control is used internally to implement PRAGMA 
    mmap_size. }
  SQLITE_FCNTL_MMAP_SIZE                                            = 18;

  { The SQLITE_FCNTL_TRACE file control provides advisory information to the VFS 
    about what the higher layers of the SQLite stack are doing. This file 
    control is used by some VFS activity tracing shims. The argument is a 
    zero-terminated string. Higher layers in the SQLite stack may generate 
    instances of this file control if the SQLITE_USE_FCNTL_TRACE compile-time 
    option is enabled. }
  SQLITE_FCNTL_TRACE                                                = 19;

  { The SQLITE_FCNTL_HAS_MOVED file control interprets its argument as a pointer 
    to an integer and it writes a boolean into that integer depending on whether 
    or not the file has been renamed, moved, or deleted since it was first 
    opened. }
  SQLITE_FCNTL_HAS_MOVED                                            = 20;

  { The SQLITE_FCNTL_SYNC opcode is generated internally by SQLite and sent to 
    the VFS immediately before the xSync method is invoked on a database file 
    descriptor. Or, if the xSync method is not invoked because the user has 
    configured SQLite with PRAGMA synchronous=OFF it is invoked in place of the 
    xSync method. In most cases, the pointer argument passed with this 
    file-control is NULL. However, if the database file is being synced as part 
    of a multi-database commit, the argument points to a nul-terminated string 
    containing the transactions super-journal file name. VFSes that do not need 
    this signal should silently ignore this opcode. Applications should not call 
    sqlite3_file_control() with this opcode as doing so may disrupt the 
    operation of the specialized VFSes that do require it. }
  SQLITE_FCNTL_SYNC                                                 = 21;

  { The SQLITE_FCNTL_COMMIT_PHASETWO opcode is generated internally by SQLite 
    and sent to the VFS after a transaction has been committed immediately but 
    before the database is unlocked. VFSes that do not need this signal should 
    silently ignore this opcode. Applications should not call 
    sqlite3_file_control() with this opcode as doing so may disrupt the 
    operation of the specialized VFSes that do require it. }
  SQLITE_FCNTL_COMMIT_PHASETWO                                      = 22;

  { The SQLITE_FCNTL_WIN32_SET_HANDLE opcode is used for debugging. This opcode 
    causes the xFileControl method to swap the file handle with the one pointed 
    to by the pArg argument. This capability is used during testing and only 
    needs to be supported when SQLITE_TEST is defined. }
  SQLITE_FCNTL_WIN32_SET_HANDLE                                     = 23;

  { The SQLITE_FCNTL_WAL_BLOCK is a signal to the VFS layer that it might be 
    advantageous to block on the next WAL lock if the lock is not immediately 
    available. The WAL subsystem issues this signal during rare circumstances in 
    order to fix a problem with priority inversion. Applications should not use 
    this file-control. }
  SQLITE_FCNTL_WAL_BLOCK                                            = 24;

  { The SQLITE_FCNTL_ZIPVFS opcode is implemented by zipvfs only. All other VFS 
    should return SQLITE_NOTFOUND for this opcode. }
  SQLITE_FCNTL_ZIPVFS                                               = 25;

  { The SQLITE_FCNTL_RBU opcode is implemented by the special VFS used by the 
    RBU extension only. All other VFS should return SQLITE_NOTFOUND for this 
    opcode. }
  SQLITE_FCNTL_RBU                                                  = 26;

  { The SQLITE_FCNTL_VFS_POINTER opcode finds a pointer to the top-level VFSes 
    currently in use. The argument X in 
    sqlite3_file_control(db,SQLITE_FCNTL_VFS_POINTER,X) must be of type 
    "sqlite3_vfs **". This opcodes will set *X to a pointer to the top-level 
    VFS. When there are multiple VFS shims in the stack, this opcode finds the 
    upper-most shim only. }
  SQLITE_FCNTL_VFS_POINTER                                          = 27;

  { The SQLITE_FCNTL_JOURNAL_POINTER opcode is used to obtain a pointer to the 
    sqlite3_file object associated with the journal file (either the rollback 
    journal or the write-ahead log) for a particular database connection. See 
    also SQLITE_FCNTL_FILE_POINTER. }
  SQLITE_FCNTL_JOURNAL_POINTER                                      = 28;

  { The SQLITE_FCNTL_WIN32_GET_HANDLE opcode can be used to obtain the 
    underlying native file handle associated with a file handle. This file 
    control interprets its argument as a pointer to a native file handle and 
    writes the resulting value there. }
  SQLITE_FCNTL_WIN32_GET_HANDLE                                     = 29;

  SQLITE_FCNTL_PDB                                                  = 30;

  { If the SQLITE_FCNTL_BEGIN_ATOMIC_WRITE opcode returns SQLITE_OK, then the 
    file descriptor is placed in "batch write mode", which means all subsequent 
    write operations will be deferred and done atomically at the next 
    SQLITE_FCNTL_COMMIT_ATOMIC_WRITE. Systems that do not support batch atomic 
    writes will return SQLITE_NOTFOUND. Following a successful 
    SQLITE_FCNTL_BEGIN_ATOMIC_WRITE and prior to the closing 
    SQLITE_FCNTL_COMMIT_ATOMIC_WRITE or SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE, 
    SQLite will make no VFS interface calls on the same sqlite3_file file 
    descriptor except for calls to the xWrite method and the xFileControl method 
    with SQLITE_FCNTL_SIZE_HINT. }
  SQLITE_FCNTL_BEGIN_ATOMIC_WRITE                                   = 31;

  { The SQLITE_FCNTL_COMMIT_ATOMIC_WRITE opcode causes all write operations 
    since the previous successful call to SQLITE_FCNTL_BEGIN_ATOMIC_WRITE to be 
    performed atomically. This file control returns SQLITE_OK if and only if the 
    writes were all performed successfully and have been committed to persistent 
    storage. Regardless of whether or not it is successful, this file control 
    takes the file descriptor out of batch write mode so that all subsequent 
    write operations are independent. SQLite will never invoke 
    SQLITE_FCNTL_COMMIT_ATOMIC_WRITE without a prior successful call to 
    SQLITE_FCNTL_BEGIN_ATOMIC_WRITE. }
  SQLITE_FCNTL_COMMIT_ATOMIC_WRITE                                  = 32;

  { The SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE opcode causes all write operations 
    since the previous successful call to SQLITE_FCNTL_BEGIN_ATOMIC_WRITE to be 
    rolled back. This file control takes the file descriptor out of batch write 
    mode so that all subsequent write operations are independent. SQLite will 
    never invoke SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE without a prior successful 
    call to SQLITE_FCNTL_BEGIN_ATOMIC_WRITE. }
  SQLITE_FCNTL_ROLLBACK_ATOMIC_WRITE                                = 33;

  { The SQLITE_FCNTL_LOCK_TIMEOUT opcode is used to configure a VFS to block for 
    up to M milliseconds before failing when attempting to obtain a file lock 
    using the xLock or xShmLock methods of the VFS. The parameter is a pointer 
    to a 32-bit signed integer that contains the value that M is to be set to. 
    Before returning, the 32-bit signed integer is overwritten with the previous 
    value of M. }
  SQLITE_FCNTL_LOCK_TIMEOUT                                         = 34;

  { The SQLITE_FCNTL_DATA_VERSION opcode is used to detect changes to a database 
    file. The argument is a pointer to a 32-bit unsigned integer. The "data 
    version" for the pager is written into the pointer. The "data version" 
    changes whenever any change occurs to the corresponding database file, 
    either through SQL statements on the same database connection or through 
    transactions committed by separate database connections possibly in other 
    processes. The sqlite3_total_changes() interface can be used to find if any 
    database on the connection has changed, but that interface responds to 
    changes on TEMP as well as MAIN and does not provide a mechanism to detect 
    changes to MAIN only. Also, the sqlite3_total_changes() interface responds 
    to internal changes only and omits changes made by other database 
    connections. The PRAGMA data_version command provides a mechanism to detect 
    changes to a single attached database that occur due to other database 
    connections, but omits changes implemented by the database connection on 
    which it is called. This file control is the only mechanism to detect 
    changes that happen either internally or externally and that are associated 
    with a particular attached database. }
  SQLITE_FCNTL_DATA_VERSION                                         = 35;

  { The SQLITE_FCNTL_SIZE_LIMIT opcode is used by in-memory VFS that implements 
    sqlite3_deserialize() to set an upper bound on the size of the in-memory 
    database. The argument is a pointer to a sqlite3_int64. If the integer 
    pointed to is negative, then it is filled in with the current limit. 
    Otherwise the limit is set to the larger of the value of the integer pointed 
    to and the current database size. The integer pointed to is set to the new 
    limit. }
  SQLITE_FCNTL_SIZE_LIMIT                                           = 36;

  { The SQLITE_FCNTL_CKPT_DONE opcode is invoked from within a checkpoint in wal 
    mode after the client has finished copying pages from the wal file to the 
    database file, but before the *-shm file is updated to record the fact that 
    the pages have been checkpointed. }
  SQLITE_FCNTL_CKPT_DONE                                            = 37;

  SQLITE_FCNTL_RESERVE_BYTES                                        = 38;

  { The SQLITE_FCNTL_CKPT_START opcode is invoked from within a checkpoint in 
    wal mode before the client starts to copy pages from the wal file to the 
    database file. }
  SQLITE_FCNTL_CKPT_START                                           = 39;

  { deprecated names }
  SQLITE_GET_LOCKPROXYFILE                     = SQLITE_FCNTL_GET_LOCKPROXYFILE;
  SQLITE_SET_LOCKPROXYFILE                     = SQLITE_FCNTL_SET_LOCKPROXYFILE;
  SQLITE_LAST_ERRNO                            = SQLITE_FCNTL_LAST_ERRNO;

  { These integer constants can be used as the third parameter to the xAccess 
    method of an sqlite3_vfs object. They determine what kind of permissions the 
    xAccess method is looking for. With SQLITE_ACCESS_EXISTS, the xAccess method 
    simply checks whether the file exists. With SQLITE_ACCESS_READWRITE, the 
    xAccess method checks whether the named directory is both readable and 
    writable (in other words, if files can be added, removed, and renamed within 
    the directory). The SQLITE_ACCESS_READWRITE constant is currently used only 
    by the temp_store_directory pragma, though this could change in a future 
    release of SQLite. With SQLITE_ACCESS_READ, the xAccess method checks 
    whether the file is readable. The SQLITE_ACCESS_READ constant is currently 
    unused, though it might be used in a future release of SQLite. }
  SQLITE_ACCESS_EXISTS                                              = 0;
  SQLITE_ACCESS_READWRITE { Used by PRAGMA temp_store_directory }   = 1;
  SQLITE_ACCESS_READ      { Unused }                                = 2;

  { These integer constants define the various locking operations allowed by the 
    xShmLock method of sqlite3_io_methods. 
    
    When unlocking, the same SHARED or EXCLUSIVE flag must be supplied as was 
    given on the corresponding lock.

    The xShmLock method can transition between unlocked and SHARED or between 
    unlocked and EXCLUSIVE. It cannot transition between SHARED and EXCLUSIVE. }
  SQLITE_SHM_UNLOCK                                                 = 1;
  SQLITE_SHM_LOCK                                                   = 2;
  SQLITE_SHM_SHARED                                                 = 4;
  SQLITE_SHM_EXCLUSIVE                                              = 8;

  { The xShmLock method on sqlite3_io_methods may use values between 0 and this 
    upper bound as its "offset" argument. The SQLite core will never attempt to 
    acquire or release a lock outside of this range. }
  SQLITE_SHM_NLOCK                                                  = 8;

  { These constants are the available integer configuration options that can be 
    passed as the first argument to the sqlite3_config() interface.

    New configuration options may be added in future releases of SQLite. 
    Existing configuration options might be discontinued. Applications should 
    check the return code from sqlite3_config() to make sure that the call 
    worked. The sqlite3_config() interface will return a non-zero error code if 
    a discontinued or unsupported configuration option is invoked. }

  { There are no arguments to this option. This option sets the threading mode 
    to Single-thread. In other words, it disables all mutexing and puts SQLite 
    into a mode where it can only be used by a single thread. If SQLite is 
    compiled with the SQLITE_THREADSAFE=0 compile-time option then it is not 
    possible to change the threading mode from its default value of 
    Single-thread and so sqlite3_config() will return SQLITE_ERROR if called 
    with the SQLITE_CONFIG_SINGLETHREAD configuration option. }
  SQLITE_CONFIG_SINGLETHREAD        { nil }                         = 1;

  { There are no arguments to this option. This option sets the threading mode 
    to Multi-thread. In other words, it disables mutexing on database connection 
    and prepared statement objects. The application is responsible for 
    serializing access to database connections and prepared statements. But 
    other mutexes are enabled so that SQLite will be safe to use in a 
    multi-threaded environment as long as no two threads attempt to use the same 
    database connection at the same time. If SQLite is compiled with the 
    SQLITE_THREADSAFE=0 compile-time option then it is not possible to set the 
    Multi-thread threading mode and sqlite3_config() will return SQLITE_ERROR if 
    called with the SQLITE_CONFIG_MULTITHREAD configuration option. }
  SQLITE_CONFIG_MULTITHREAD         { nil }                         = 2;

  { There are no arguments to this option. This option sets the threading mode 
    to Serialized. In other words, this option enables all mutexes including the 
    recursive mutexes on database connection and prepared statement objects. In 
    this mode (which is the default when SQLite is compiled with 
    SQLITE_THREADSAFE=1) the SQLite library will itself serialize access to 
    database connections and prepared statements so that the application is free 
    to use the same database connection or the same prepared statement in 
    different threads at the same time. If SQLite is compiled with the 
    SQLITE_THREADSAFE=0 compile-time option then it is not possible to set the 
    Serialized threading mode and sqlite3_config() will return SQLITE_ERROR if 
    called with the SQLITE_CONFIG_SERIALIZED configuration option. }
  SQLITE_CONFIG_SERIALIZED          { nil }                         = 3;

  { The SQLITE_CONFIG_MALLOC option takes a single argument which is a pointer 
    to an instance of the sqlite3_mem_methods structure. The argument specifies 
    alternative low-level memory allocation routines to be used in place of the 
    memory allocation routines built into SQLite. SQLite makes its own private 
    copy of the content of the sqlite3_mem_methods structure before the 
    sqlite3_config() call returns. }
  SQLITE_CONFIG_MALLOC              { psqlite3_mem_methods }        = 4;

  { The SQLITE_CONFIG_GETMALLOC option takes a single argument which is a 
    pointer to an instance of the sqlite3_mem_methods structure. The 
    sqlite3_mem_methods structure is filled with the currently defined memory 
    allocation routines. This option can be used to overload the default memory 
    allocation routines with a wrapper that simulations memory allocation 
    failure or tracks memory usage, for example. }
  SQLITE_CONFIG_GETMALLOC           { psqlite3_mem_methods }        = 5;

  { The SQLITE_CONFIG_SCRATCH option is no longer used.  }
  SQLITE_CONFIG_SCRATCH             { No longer used }              = 6;

  { The SQLITE_CONFIG_PAGECACHE option specifies a memory pool that SQLite can 
    use for the database page cache with the default page cache implementation. 
    This configuration option is a no-op if an application-defined page cache 
    implementation is loaded using the SQLITE_CONFIG_PCACHE2. There are three 
    arguments to SQLITE_CONFIG_PAGECACHE: A pointer to 8-byte aligned memory 
    (pMem), the size of each page cache line (sz), and the number of cache lines 
    (N). The sz argument should be the size of the largest database page (a 
    power of two between 512 and 65536) plus some extra bytes for each page 
    header. The number of extra bytes needed by the page header can be 
    determined using SQLITE_CONFIG_PCACHE_HDRSZ. It is harmless, apart from the 
    wasted memory, for the sz parameter to be larger than necessary. The pMem 
    argument must be either a NULL pointer or a pointer to an 8-byte aligned 
    block of memory of at least sz*N bytes, otherwise subsequent behavior is 
    undefined. When pMem is not NULL, SQLite will strive to use the memory 
    provided to satisfy page cache needs, falling back to sqlite3_malloc() if a 
    page cache line is larger than sz bytes or if all of the pMem buffer is 
    exhausted. If pMem is NULL and N is non-zero, then each database connection 
    does an initial bulk allocation for page cache memory from sqlite3_malloc() 
    sufficient for N cache lines if N is positive or of -1024*N bytes if N is 
    negative, . If additional page cache memory is needed beyond what is 
    provided by the initial allocation, then SQLite goes to sqlite3_malloc() 
    separately for each additional cache line. } 
  SQLITE_CONFIG_PAGECACHE           { void*, int sz, int N }        = 7;

  { The SQLITE_CONFIG_HEAP option specifies a static memory buffer that SQLite 
    will use for all of its dynamic memory allocation needs beyond those 
    provided for by SQLITE_CONFIG_PAGECACHE. The SQLITE_CONFIG_HEAP option is 
    only available if SQLite is compiled with either SQLITE_ENABLE_MEMSYS3 or 
    SQLITE_ENABLE_MEMSYS5 and returns SQLITE_ERROR if invoked otherwise. There 
    are three arguments to SQLITE_CONFIG_HEAP: An 8-byte aligned pointer to the 
    memory, the number of bytes in the memory buffer, and the minimum allocation 
    size. If the first pointer (the memory pointer) is NULL, then SQLite reverts 
    to using its default memory allocator (the system malloc() implementation), 
    undoing any prior invocation of SQLITE_CONFIG_MALLOC. If the memory pointer 
    is not NULL then the alternative memory allocator is engaged to handle all 
    of SQLites memory allocation needs. The first pointer (the memory pointer) 
    must be aligned to an 8-byte boundary or subsequent behavior of SQLite will 
    be undefined. The minimum allocation size is capped at 2**12. Reasonable 
    values for the minimum allocation size are 2**5 through 2**8. }
  SQLITE_CONFIG_HEAP                { void*, int nByte, int min }   = 8;

  { The SQLITE_CONFIG_MEMSTATUS option takes single argument of type int, 
    interpreted as a boolean, which enables or disables the collection of memory 
    allocation statistics. When memory allocation statistics are disabled, the 
    following SQLite interfaces become non-operational:

    sqlite3_hard_heap_limit64()
    sqlite3_memory_used()
    sqlite3_memory_highwater()
    sqlite3_soft_heap_limit64()
    sqlite3_status64() 

    Memory allocation statistics are enabled by default unless SQLite is 
    compiled with SQLITE_DEFAULT_MEMSTATUS=0 in which case memory allocation 
    statistics are disabled by default. }
  SQLITE_CONFIG_MEMSTATUS           { boolean }                     = 9;

  { The SQLITE_CONFIG_MUTEX option takes a single argument which is a pointer to 
    an instance of the sqlite3_mutex_methods structure. The argument specifies 
    alternative low-level mutex routines to be used in place the mutex routines 
    built into SQLite. SQLite makes a copy of the content of the 
    sqlite3_mutex_methods structure before the call to sqlite3_config() returns. 
    If SQLite is compiled with the SQLITE_THREADSAFE=0 compile-time option then 
    the entire mutexing subsystem is omitted from the build and hence calls to 
    sqlite3_config() with the SQLITE_CONFIG_MUTEX configuration option will 
    return SQLITE_ERROR. }
  SQLITE_CONFIG_MUTEX               { psqlite3_mutex_methods }      = 10;

  { The SQLITE_CONFIG_GETMUTEX option takes a single argument which is a pointer 
    to an instance of the sqlite3_mutex_methods structure. The 
    sqlite3_mutex_methods structure is filled with the currently defined mutex 
    routines. This option can be used to overload the default mutex allocation 
    routines with a wrapper used to track mutex usage for performance profiling 
    or testing, for example. If SQLite is compiled with the SQLITE_THREADSAFE=0 
    compile-time option then the entire mutexing subsystem is omitted from the
    build and hence calls to sqlite3_config() with the SQLITE_CONFIG_GETMUTEX 
    configuration option will return SQLITE_ERROR. }
  SQLITE_CONFIG_GETMUTEX            { psqlite3_mutex_methods }      = 11;

  { previously, which is now unused }
  { SQLITE_CONFIG_CHUNKALLOC                                          = 12; }

  { The SQLITE_CONFIG_LOOKASIDE option takes two arguments that determine the 
    default size of lookaside memory on each database connection. The first 
    argument is the size of each lookaside buffer slot and the second is the 
    number of slots allocated to each database connection. 
    SQLITE_CONFIG_LOOKASIDE sets the default lookaside size. The 
    SQLITE_DBCONFIG_LOOKASIDE option to sqlite3_db_config() can be used to 
    change the lookaside configuration on individual connections. }
  SQLITE_CONFIG_LOOKASIDE           { int int }                     = 13;

  { These options are obsolete and should not be used by new code. They are 
    retained for backwards compatibility but are now no-ops. }
  SQLITE_CONFIG_PCACHE              { no-op }                       = 14;
  SQLITE_CONFIG_GETPCACHE           { no-op }                       = 15;

  { The SQLITE_CONFIG_LOG option is used to configure the SQLite global error 
    log. (The SQLITE_CONFIG_LOG option takes two arguments: a pointer to a 
    function with a call signature of void(*)(void*,int,const char*), and a 
    pointer to void. If the function pointer is not NULL, it is invoked by 
    sqlite3_log() to process each logging event. If the function pointer is 
    NULL, the sqlite3_log() interface becomes a no-op. The void pointer that is 
    the second argument to SQLITE_CONFIG_LOG is passed through as the first 
    parameter to the application-defined logger function whenever that function 
    is invoked. The second parameter to the logger function is a copy of the 
    first parameter to the corresponding sqlite3_log() call and is intended to 
    be a result code or an extended result code. The third parameter passed to 
    the logger is log message after formatting via sqlite3_snprintf(). The 
    SQLite logging interface is not reentrant; the logger function supplied by 
    the application must not invoke any SQLite interface. In a multi-threaded 
    application, the application-defined logger function must be threadsafe. }
  SQLITE_CONFIG_LOG                 { xFunc, void* }                = 16;

  { The SQLITE_CONFIG_URI option takes a single argument of type int. If 
    non-zero, then URI handling is globally enabled. If the parameter is zero, 
    then URI handling is globally disabled. If URI handling is globally enabled, 
    all filenames passed to sqlite3_open(), sqlite3_open_v2(), sqlite3_open16() 
    or specified as part of ATTACH commands are interpreted as URIs, regardless 
    of whether or not the SQLITE_OPEN_URI flag is set when the database 
    connection is opened. If it is globally disabled, filenames are only 
    interpreted as URIs if the SQLITE_OPEN_URI flag is set when the database 
    connection is opened. By default, URI handling is globally disabled. The 
    default value may be changed by compiling with the SQLITE_USE_URI symbol 
    defined. }
  SQLITE_CONFIG_URI                 { int }                         = 17;

  { The SQLITE_CONFIG_PCACHE2 option takes a single argument which is a pointer 
    to an sqlite3_pcache_methods2 object. This object specifies the interface to 
    a custom page cache implementation. SQLite makes a copy of the 
    sqlite3_pcache_methods2 object. }
  SQLITE_CONFIG_PCACHE2             { psqlite3_pcache_methods2 }    = 18;

  { The SQLITE_CONFIG_GETPCACHE2 option takes a single argument which is a 
    pointer to an sqlite3_pcache_methods2 object. SQLite copies of the current 
    page cache implementation into that object. }
  SQLITE_CONFIG_GETPCACHE2          { psqlite3_pcache_methods2 }    = 19;

  { The SQLITE_CONFIG_COVERING_INDEX_SCAN option takes a single integer argument 
    which is interpreted as a boolean in order to enable or disable the use of 
    covering indices for full table scans in the query optimizer. The default 
    setting is determined by the SQLITE_ALLOW_COVERING_INDEX_SCAN compile-time 
    option, or is "on" if that compile-time option is omitted. The ability to 
    disable the use of covering indices for full table scans is because some 
    incorrectly coded legacy applications might malfunction when the 
    optimization is enabled. Providing the ability to disable the optimization 
    allows the older, buggy application code to work without change even with 
    newer versions of SQLite. }
  SQLITE_CONFIG_COVERING_INDEX_SCAN { int }                         = 20;

  { This option is only available if sqlite is compiled with the 
    SQLITE_ENABLE_SQLLOG pre-processor macro defined. The first argument should 
    be a pointer to a function of type void(*)(void*,sqlite3*,const char*, int). 
    The second should be of type (void*). The callback is invoked by the library 
    in three separate circumstances, identified by the value passed as the 
    fourth parameter. If the fourth parameter is 0, then the database connection 
    passed as the second argument has just been opened. The third argument 
    points to a buffer containing the name of the main database file. If the 
    fourth parameter is 1, then the SQL statement that the third parameter 
    points to has just been executed. Or, if the fourth parameter is 2, then the 
    connection being passed as the second parameter is being closed. The third 
    parameter is passed NULL In this case. An example of using this 
    configuration option can be seen in the "test_sqllog.c" source file in the 
    canonical SQLite source tree. }
  SQLITE_CONFIG_SQLLOG              { xSqllog, void* }              = 21;

  { SQLITE_CONFIG_MMAP_SIZE takes two 64-bit integer (sqlite3_int64) values that 
    are the default mmap size limit (the default setting for PRAGMA mmap_size) 
    and the maximum allowed mmap size limit. The default setting can be 
    overridden by each database connection using either the PRAGMA mmap_size 
    command, or by using the SQLITE_FCNTL_MMAP_SIZE file control. The maximum 
    allowed mmap size will be silently truncated if necessary so that it does 
    not exceed the compile-time maximum mmap size set by the 
    SQLITE_MAX_MMAP_SIZE compile-time option. If either argument to this option 
    is negative, then that argument is changed to its compile-time default. }
  SQLITE_CONFIG_MMAP_SIZE         { sqlite3_int64, sqlite3_int64 }  = 22;

  { The SQLITE_CONFIG_WIN32_HEAPSIZE option is only available if SQLite is 
    compiled for Windows with the SQLITE_WIN32_MALLOC pre-processor macro 
    defined. SQLITE_CONFIG_WIN32_HEAPSIZE takes a 32-bit unsigned integer value 
    that specifies the maximum size of the created heap. }
  SQLITE_CONFIG_WIN32_HEAPSIZE    { int nByte }                     = 23;

  { The SQLITE_CONFIG_PCACHE_HDRSZ option takes a single parameter which is a 
    pointer to an integer and writes into that integer the number of extra bytes 
    per page required for each page in SQLITE_CONFIG_PAGECACHE. The amount of 
    extra space required can change depending on the compiler, target platform, 
    and SQLite version. }
  SQLITE_CONFIG_PCACHE_HDRSZ      { int *psz }                      = 24;

  { The SQLITE_CONFIG_PMASZ option takes a single parameter which is an unsigned 
    integer and sets the "Minimum PMA Size" for the multithreaded sorter to that 
    integer. The default minimum PMA Size is set by the SQLITE_SORTER_PMASZ 
    compile-time option. New threads are launched to help with sort operations 
    when multithreaded sorting is enabled (using the PRAGMA threads command) and 
    the amount of content to be sorted exceeds the page size times the minimum 
    of the PRAGMA cache_size setting and this value. }  
  SQLITE_CONFIG_PMASZ             { unsigned int szPma }            = 25;

  { The SQLITE_CONFIG_STMTJRNL_SPILL option takes a single parameter which 
    becomes the statement journal spill-to-disk threshold. Statement journals 
    are held in memory until their size (in bytes) exceeds this threshold, at 
    which point they are written to disk. Or if the threshold is -1, statement 
    journals are always held exclusively in memory. Since many statement 
    journals never become large, setting the spill threshold to a value such as 
    64KiB can greatly reduce the amount of I/O required to support statement 
    rollback. The default value for this setting is controlled by the 
    SQLITE_STMTJRNL_SPILL compile-time option. }
  SQLITE_CONFIG_STMTJRNL_SPILL    { int nByte }                     = 26;

  { The SQLITE_CONFIG_SMALL_MALLOC option takes single argument of type int, 
    interpreted as a boolean, which if true provides a hint to SQLite that it 
    should avoid large memory allocations if possible. SQLite will run faster if 
    it is free to make large memory allocations, but some application might 
    prefer to run slower in exchange for guarantees about memory fragmentation 
    that are possible if large allocations are avoided. This hint is normally 
    off. }  
  SQLITE_CONFIG_SMALL_MALLOC      { boolean }                       = 27;

  { The SQLITE_CONFIG_SORTERREF_SIZE option accepts a single parameter of type 
    (int) - the new value of the sorter-reference size threshold. Usually, when 
    SQLite uses an external sort to order records according to an ORDER BY 
    clause, all fields required by the caller are present in the sorted records. 
    However, if SQLite determines based on the declared type of a table column 
    that its values are likely to be very large - larger than the configured 
    sorter-reference size threshold - then a reference is stored in each sorted 
    record and the required column values loaded from the database as records 
    are returned in sorted order. The default value for this option is to never 
    use this optimization. Specifying a negative value for this option restores 
    the default behaviour. This option is only available if SQLite is compiled 
    with the SQLITE_ENABLE_SORTER_REFERENCES compile-time option. }
  SQLITE_CONFIG_SORTERREF_SIZE    { int nByte }                     = 28;

  { The SQLITE_CONFIG_MEMDB_MAXSIZE option accepts a single parameter 
    sqlite3_int64 parameter which is the default maximum size for an in-memory 
    database created using sqlite3_deserialize(). This default maximum size can 
    be adjusted up or down for individual databases using the 
    SQLITE_FCNTL_SIZE_LIMIT file-control. If this configuration setting is never 
    used, then the default maximum is determined by the 
    SQLITE_MEMDB_DEFAULT_MAXSIZE compile-time option. If that compile-time 
    option is not set, then the default maximum is 1073741824. }
  SQLITE_CONFIG_MEMDB_MAXSIZE     { sqlite3_int64 }                 = 29;

  { These constants are the available integer configuration options that can be 
    passed as the second argument to the sqlite3_db_config() interface.

    New configuration options may be added in future releases of SQLite. 
    Existing configuration options might be discontinued. Applications should 
    check the return code from sqlite3_db_config() to make sure that the call 
    worked. The sqlite3_db_config() interface will return a non-zero error code 
    if a discontinued or unsupported configuration option is invoked. }
  
  { This option is used to change the name of the "main" database schema. The 
    sole argument is a pointer to a constant UTF8 string which will become the 
    new schema name in place of "main". SQLite does not make a copy of the new
    main schema name string, so the application must ensure that the argument 
    passed into this DBCONFIG option is unchanged until after the database 
    connection closes. }
  SQLITE_DBCONFIG_MAINDBNAME     { const char* }                    = 1000;

  { This option takes three additional arguments that determine the lookaside 
    memory allocator configuration for the database connection. The first 
    argument (the third parameter to sqlite3_db_config() is a pointer to a 
    memory buffer to use for lookaside memory. The first argument after the 
    SQLITE_DBCONFIG_LOOKASIDE verb may be NULL in which case SQLite will 
    allocate the lookaside buffer itself using sqlite3_malloc(). The second 
    argument is the size of each lookaside buffer slot. The third argument is 
    the number of slots. The size of the buffer in the first argument must be 
    greater than or equal to the product of the second and third arguments. The 
    buffer must be aligned to an 8-byte boundary. If the second argument to 
    SQLITE_DBCONFIG_LOOKASIDE is not a multiple of 8, it is internally rounded 
    down to the next smaller multiple of 8. The lookaside memory configuration 
    for a database connection can only be changed when that connection is not 
    currently using lookaside memory, or in other words when the "current value" 
    returned by sqlite3_db_status(D,SQLITE_CONFIG_LOOKASIDE,...) is zero. Any 
    attempt to change the lookaside memory configuration when lookaside memory 
    is in use leaves the configuration unchanged and returns SQLITE_BUSY. }
  SQLITE_DBCONFIG_LOOKASIDE     { void* int int }                   = 1001;

  { This option is used to enable or disable the enforcement of foreign key 
    constraints. There should be two additional arguments. The first argument is 
    an integer which is 0 to disable FK enforcement, positive to enable FK 
    enforcement or negative to leave FK enforcement unchanged. The second 
    parameter is a pointer to an integer into which is written 0 or 1 to 
    indicate whether FK enforcement is off or on following this call. The second 
    parameter may be a NULL pointer, in which case the FK enforcement setting is 
    not reported back. }
  SQLITE_DBCONFIG_ENABLE_FKEY   { int int* }                        = 1002;

  { This option is used to enable or disable triggers. There should be two 
    additional arguments. The first argument is an integer which is 0 to disable 
    triggers, positive to enable triggers or negative to leave the setting 
    unchanged. The second parameter is a pointer to an integer into which is 
    written 0 or 1 to indicate whether triggers are disabled or enabled 
    following this call. The second parameter may be a NULL pointer, in which 
    case the trigger setting is not reported back. }
  SQLITE_DBCONFIG_ENABLE_TRIGGER  { int int* }                      = 1003;

  { This option is used to enable or disable the fts3_tokenizer() function which 
    is part of the FTS3 full-text search engine extension. There should be two 
    additional arguments. The first argument is an integer which is 0 to disable 
    fts3_tokenizer() or positive to enable fts3_tokenizer() or negative to leave 
    the setting unchanged. The second parameter is a pointer to an integer into 
    which is written 0 or 1 to indicate whether fts3_tokenizer is disabled or 
    enabled following this call. The second parameter may be a NULL pointer, in 
    which case the new setting is not reported back. }
  SQLITE_DBCONFIG_ENABLE_FTS3_TOKENIZER  { int int* }               = 1004;

  { This option is used to enable or disable the sqlite3_load_extension()
    interface independently of the load_extension() SQL function. The 
    sqlite3_enable_load_extension() API enables or disables both the C-API 
    sqlite3_load_extension() and the SQL function load_extension(). There should 
    be two additional arguments. When the first argument to this interface is 1, 
    then only the C-API is enabled and the SQL function remains disabled. If the 
    first argument to this interface is 0, then both the C-API and the SQL 
    function are disabled. If the first argument is -1, then no changes are made 
    to state of either the C-API or the SQL function. The second parameter is a 
    pointer to an integer into which is written 0 or 1 to indicate whether 
    sqlite3_load_extension() interface is disabled or enabled following this 
    call. The second parameter may be a NULL pointer, in which case the new 
    setting is not reported back. }
  SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION { int int* }                = 1005;

  { Usually, when a database in wal mode is closed or detached from a database 
    handle, SQLite checks if this will mean that there are now no connections at 
    all to the database. If so, it performs a checkpoint operation before 
    closing the connection. This option may be used to override this behaviour. 
    The first parameter passed to this operation is an integer - positive to 
    disable checkpoints-on-close, or zero (the default) to enable them, and 
    negative to leave the setting unchanged. The second parameter is a pointer 
    to an integer into which is written 0 or 1 to indicate whether 
    checkpoints-on-close have been disabled - 0 if they are not disabled, 1 if 
    they are. }
  SQLITE_DBCONFIG_NO_CKPT_ON_CLOSE    { int int* }                  = 1006;

  { The SQLITE_DBCONFIG_ENABLE_QPSG option activates or deactivates the query 
    planner stability guarantee (QPSG). When the QPSG is active, a single SQL 
    query statement will always use the same algorithm regardless of values of 
    bound parameters. The QPSG disables some query optimizations that look at 
    the values of bound parameters, which can make some queries slower. But the 
    QPSG has the advantage of more predictable behavior. With the QPSG active, 
    SQLite will always use the same query plan in the field as was used during 
    testing in the lab. The first argument to this setting is an integer which 
    is 0 to disable the QPSG, positive to enable QPSG, or negative to leave the 
    setting unchanged. The second parameter is a pointer to an integer into 
    which is written 0 or 1 to indicate whether the QPSG is disabled or enabled 
    following this call. }
  SQLITE_DBCONFIG_ENABLE_QPSG         { int int* }                  = 1007;

  { By default, the output of EXPLAIN QUERY PLAN commands does not include 
    output for any operations performed by trigger programs. This option is used 
    to set or clear (the default) a flag that governs this behavior. The first 
    parameter passed to this operation is an integer - positive to enable output 
    for trigger programs, or zero to disable it, or negative to leave the 
    setting unchanged. The second parameter is a pointer to an integer into 
    which is written 0 or 1 to indicate whether output-for-triggers has been 
    disabled - 0 if it is not disabled, 1 if it is. }
  SQLITE_DBCONFIG_TRIGGER_EQP         { int int* }                  = 1008;

  { Set the SQLITE_DBCONFIG_RESET_DATABASE flag and then run VACUUM in order to 
    reset a database back to an empty database with no schema and no content. 
    The following process works even for a badly corrupted database file:

    If the database connection is newly opened, make sure it has read the 
      database schema by preparing then discarding some query against the 
      database, or calling sqlite3_table_column_metadata(), ignoring any errors. 
      This step is only necessary if the application desires to keep the 
      database in WAL mode after the reset if it was in WAL mode before the 
      reset.
    sqlite3_db_config(db, SQLITE_DBCONFIG_RESET_DATABASE, 1, 0);
    sqlite3_exec(db, "VACUUM", 0, 0, 0);
    sqlite3_db_config(db, SQLITE_DBCONFIG_RESET_DATABASE, 0, 0); 

    Because resetting a database is destructive and irreversible, the process 
    requires the use of this obscure API and multiple steps to help ensure that 
    it does not happen by accident. }
  SQLITE_DBCONFIG_RESET_DATABASE      { int int* }                  = 1009;

  { The SQLITE_DBCONFIG_DEFENSIVE option activates or deactivates the 
    "defensive" flag for a database connection. When the defensive flag is 
    enabled, language features that allow ordinary SQL to deliberately corrupt 
    the database file are disabled. The disabled features include but are not 
    limited to the following:

    The PRAGMA writable_schema=ON statement.
    The PRAGMA journal_mode=OFF statement.
    Writes to the sqlite_dbpage virtual table.
    Direct writes to shadow tables. }
   SQLITE_DBCONFIG_DEFENSIVE          { int int* }                  = 1010;

   { The SQLITE_DBCONFIG_WRITABLE_SCHEMA option activates or deactivates the 
    "writable_schema" flag. This has the same effect and is logically equivalent 
    to setting PRAGMA writable_schema=ON or PRAGMA writable_schema=OFF. The 
    first argument to this setting is an integer which is 0 to disable the 
    writable_schema, positive to enable writable_schema, or negative to leave 
    the setting unchanged. The second parameter is a pointer to an integer into 
    which is written 0 or 1 to indicate whether the writable_schema is enabled 
    or disabled following this call. }
  SQLITE_DBCONFIG_WRITABLE_SCHEMA     { int int* }                  = 1011;

  { The SQLITE_DBCONFIG_LEGACY_ALTER_TABLE option activates or deactivates the 
    legacy behavior of the ALTER TABLE RENAME command such it behaves as it did 
    prior to version 3.24.0 (2018-06-04). See the "Compatibility Notice" on the 
    ALTER TABLE RENAME documentation for additional information. This feature 
    can also be turned on and off using the PRAGMA legacy_alter_table 
    statement. }
  SQLITE_DBCONFIG_LEGACY_ALTER_TABLE  { int int* }                  = 1012;

  { The SQLITE_DBCONFIG_DQS_DML option activates or deactivates the legacy 
    double-quoted string literal misfeature for DML statements only, that is 
    DELETE, INSERT, SELECT, and UPDATE statements. The default value of this 
    setting is determined by the -DSQLITE_DQS compile-time option. }
  SQLITE_DBCONFIG_DQS_DML             { int int* }                  = 1013;

  { The SQLITE_DBCONFIG_DQS option activates or deactivates the legacy 
    double-quoted string literal misfeature for DDL statements, such as CREATE 
    TABLE and CREATE INDEX. The default value of this setting is determined by 
    the -DSQLITE_DQS compile-time option. }
  SQLITE_DBCONFIG_DQS_DDL             { int int* }                  = 1014;

  { This option is used to enable or disable views. There should be two 
    additional arguments. The first argument is an integer which is 0 to disable 
    views, positive to enable views or negative to leave the setting unchanged. 
    The second parameter is a pointer to an integer into which is written 0 or 1 
    to indicate whether views are disabled or enabled following this call. The 
    second parameter may be a NULL pointer, in which case the view setting is 
    not reported back. }
  SQLITE_DBCONFIG_ENABLE_VIEW         { int int* }                  = 1015;

  { The SQLITE_DBCONFIG_LEGACY_FILE_FORMAT option activates or deactivates the 
    legacy file format flag. When activated, this flag causes all newly created 
    database file to have a schema format version number (the 4-byte integer 
    found at offset 44 into the database header) of 1. This in turn means that 
    the resulting database file will be readable and writable by any SQLite 
    version back to 3.0.0 (2004-06-18). Without this setting, newly created 
    databases are generally not understandable by SQLite versions prior to 3.3.0 
    (2006-01-11). As these words are written, there is now scarcely any need to 
    generated database files that are compatible all the way back to version 
    3.0.0, and so this setting is of little practical use, but is provided so 
    that SQLite can continue to claim the ability to generate new database files 
    that are compatible with version 3.0.0.

    Note that when the SQLITE_DBCONFIG_LEGACY_FILE_FORMAT setting is on, the 
    VACUUM command will fail with an obscure error when attempting to process a 
    table with generated columns and a descending index. This is not considered 
    a bug since SQLite versions 3.3.0 and earlier do not support either 
    generated columns or decending indexes. }
  SQLITE_DBCONFIG_LEGACY_FILE_FORMAT  { int int* }                  = 1016;

  { The SQLITE_DBCONFIG_TRUSTED_SCHEMA option tells SQLite to assume that 
    database schemas are untainted by malicious content. When the 
    SQLITE_DBCONFIG_TRUSTED_SCHEMA option is disabled, SQLite takes additional 
    defensive steps to protect the application from harm including:

    Prohibit the use of SQL functions inside triggers, views, CHECK constraints, 
    DEFAULT clauses, expression indexes, partial indexes, or generated columns 
    unless those functions are tagged with SQLITE_INNOCUOUS.
    
    Prohibit the use of virtual tables inside of triggers or views unless those 
    virtual tables are tagged with SQLITE_VTAB_INNOCUOUS. 

    This setting defaults to "on" for legacy compatibility, however all 
    applications are advised to turn it off if possible. This setting can also 
    be controlled using the PRAGMA trusted_schema statement. }
  SQLITE_DBCONFIG_TRUSTED_SCHEMA    { int int* }                    = 1017;
  SQLITE_DBCONFIG_MAX               { Largest DBCONFIG }            = 1017;

  { The authorizer callback function must return either SQLITE_OK or one of 
    these two constants in order to signal SQLite whether or not the action is 
    permitted. See the authorizer documentation for additional information.

    Note that SQLITE_IGNORE is also used as a conflict resolution mode returned 
    from the sqlite3_vtab_on_conflict() interface. }
  
  { Abort the SQL statement with an error }
  SQLITE_DENY                                                       = 1;

  { Don't allow access, but don't generate an error }
  SQLITE_IGNORE                                                     = 2;

  { The sqlite3_set_authorizer() interface registers a callback function that is 
    invoked to authorize certain SQL statement actions. The second parameter to 
    the callback is an integer code that specifies what action is being 
    authorized. These are the integer action codes that the authorizer callback 
    may be passed.

    These action code values signify what kind of operation is to be authorized. 
    The 3rd and 4th parameters to the authorization callback function will be 
    parameters or NULL depending on which of these codes is used as the second 
    parameter. The 5th parameter to the authorizer callback is the name of the 
    database ("main", "temp", etc.) if applicable. The 6th parameter to the 
    authorizer callback is the name of the inner-most trigger or view that is 
    responsible for the access attempt or NULL if this access attempt is 
    directly from top-level SQL code. }

  { * 3rd ************ 4th ********** }
  {   Index Name       Table Name     }
  SQLITE_CREATE_INDEX                                               = 1;

  { * 3rd ************ 4th ********** }
  {   Table Name       NULL           }
  SQLITE_CREATE_TABLE                                               = 2;

  { * 3rd ************ 4th ********** }
  {   Index Name       Table Name     }
  SQLITE_CREATE_TEMP_INDEX                                          = 3;

  { * 3rd ************ 4th ********** }
  {   Table Name       NULL           }
  SQLITE_CREATE_TEMP_TABLE                                          = 4;

  { * 3rd ************ 4th ********** }
  {   Trigger Name     Table Name     }
  SQLITE_CREATE_TEMP_TRIGGER                                        = 5;

  { * 3rd ************ 4th ********** }
  {   View Name        NULL           }
  SQLITE_CREATE_TEMP_VIEW                                           = 6;

  { * 3rd ************ 4th ********** }
  {   Trigger Name     Table Name     }
  SQLITE_CREATE_TRIGGER                                             = 7;

  { * 3rd ************ 4th ********** }
  {   View Name        NULL           }
  SQLITE_CREATE_VIEW                                                = 8;

  { * 3rd ************ 4th ********** }
  {   Table Name       NULL           }
  SQLITE_DELETE                                                     = 9;

  { * 3rd ************ 4th ********** }
  {   Index Name       Table Name     }
  SQLITE_DROP_INDEX                                                 = 10;

  { * 3rd ************ 4th ********** }
  {   Table Name       NULL           }
  SQLITE_DROP_TABLE                                                 = 11;

  { * 3rd ************ 4th ********** }
  {   Index Name       Table Name     }
  SQLITE_DROP_TEMP_INDEX                                            = 12;

  { * 3rd ************ 4th ********** }
  {   Table Name       NULL           }
  SQLITE_DROP_TEMP_TABLE                                            = 13;

  { * 3rd ************ 4th ********** }
  {   Trigger Name     Table Name     }
  SQLITE_DROP_TEMP_TRIGGER                                          = 14;

  { * 3rd ************ 4th ********** }
  {   View Name        NULL           }
  SQLITE_DROP_TEMP_VIEW                                             = 15;

  { * 3rd ************ 4th ********** }
  {   Trigger Name     Table Name     }
  SQLITE_DROP_TRIGGER                                               = 16;

  { * 3rd ************ 4th ********** }
  {   View Name        NULL           }
  SQLITE_DROP_VIEW                                                  = 17;

  { * 3rd ************ 4th ********** }
  {   Table Name       NULL           }
  SQLITE_INSERT                                                     = 18;

  { * 3rd ************ 4th ********** }
  {   Pragma Name      1st arg or NULL}
  SQLITE_PRAGMA                                                     = 19;

  { * 3rd ************ 4th ********** }
  {   Table Name       Column Name    }
  SQLITE_READ                                                       = 20;

  { * 3rd ************ 4th ********** }
  {   NULL             NULL           }
  SQLITE_SELECT                                                     = 21;

  { * 3rd ************ 4th ********** }
  {   Operation        NULL           }
  SQLITE_TRANSACTION                                                = 22;

  { * 3rd ************ 4th ********** }
  {   Table Name       Column Name    }
  SQLITE_UPDATE                                                     = 23;

  { * 3rd ************ 4th ********** }
  {   Filename         NULL           }
  SQLITE_ATTACH                                                     = 24;

  { * 3rd ************ 4th ********** }
  {   Database Name    NULL           }
  SQLITE_DETACH                                                     = 25;

  { * 3rd ************ 4th ********** }
  {   Database Name    Table Name     }
  SQLITE_ALTER_TABLE                                                = 26;

  { * 3rd ************ 4th ********** }
  {   Index Name       NULL           }
  SQLITE_REINDEX                                                    = 27;

  { * 3rd ************ 4th ********** }
  {   Table Name       NULL           }
  SQLITE_ANALYZE                                                    = 28;

  { * 3rd ************ 4th ********** }
  {   Table Name       Module Name    }
  SQLITE_CREATE_VTABLE                                              = 29;

  { * 3rd ************ 4th ********** }
  {   Table Name       Module Name    }
  SQLITE_DROP_VTABLE                                                = 30;

  { * 3rd ************ 4th ********** }
  {   NULL             Function Name  }
  SQLITE_FUNCTION                                                   = 31;

  { * 3rd ************ 4th ********** }
  {   Operation        Savepoint Name }
  SQLITE_SAVEPOINT                                                  = 32;

  SQLITE_COPY          { No longer used }                           = 0;

  { * 3rd ************ 4th ********** }
  {   NULL             NULL }
  SQLITE_SAVEPOINT                                                  = 33;

  { These constants identify classes of events that can be monitored using the 
    sqlite3_trace_v2() tracing logic. The M argument to 
    sqlite3_trace_v2(D,M,X,P) is an OR-ed combination of one or more of the 
    following constants. The first argument to the trace callback is one of the 
    following constants.

    New tracing constants may be added in future releases.

    A trace callback has four arguments: xCallback(T,C,P,X). The T argument is 
    one of the integer type codes above. The C argument is a copy of the context 
    pointer passed in as the fourth argument to sqlite3_trace_v2(). The P and X 
    arguments are pointers whose meanings depend on T. }
  
  { An SQLITE_TRACE_STMT callback is invoked when a prepared statement first 
    begins running and possibly at other times during the execution of the 
    prepared statement, such as at the start of each trigger subprogram. The P 
    argument is a pointer to the prepared statement. The X argument is a pointer 
    to a string which is the unexpanded SQL text of the prepared statement or an 
    SQL comment that indicates the invocation of a trigger. The callback can 
    compute the same text that would have been returned by the legacy 
    sqlite3_trace() interface by using the X argument when X begins with "--" 
    and invoking sqlite3_expanded_sql(P) otherwise. }
  SQLITE_TRACE_STMT                                                 = $01;

  { An SQLITE_TRACE_PROFILE callback provides approximately the same information 
    as is provided by the sqlite3_profile() callback. The P argument is a 
    pointer to the prepared statement and the X argument points to a 64-bit 
    integer which is the estimated of the number of nanosecond that the prepared 
    statement took to run. The SQLITE_TRACE_PROFILE callback is invoked when the 
    statement finishes. }
  SQLITE_TRACE_PROFILE                                              = $02;

  { An SQLITE_TRACE_ROW callback is invoked whenever a prepared statement 
    generates a single row of result. The P argument is a pointer to the 
    prepared statement and the X argument is unused. }
  SQLITE_TRACE_ROW                                                  = $03;

  { An SQLITE_TRACE_CLOSE callback is invoked when a database connection closes. 
    The P argument is a pointer to the database connection object and the X 
    argument is unused. }
  SQLITE_TRACE_CLOSE                                                = $04;

  { These constants define various performance limits that can be lowered at 
    run-time using sqlite3_limit(). The synopsis of the meanings of the various 
    limits is shown below. }
  
  { The maximum size of any string or BLOB or table row, in bytes. }
  SQLITE_LIMIT_LENGTH                                               = 0;

  { The maximum length of an SQL statement, in bytes. }
  SQLITE_LIMIT_SQL_LENGTH                                           = 1;

  { The maximum number of columns in a table definition or in the result set of 
    a SELECT or the maximum number of columns in an index or in an ORDER BY or 
    GROUP BY clause. }
  SQLITE_LIMIT_COLUMN                                               = 2;

  { The maximum depth of the parse tree on any expression. }
  SQLITE_LIMIT_EXPR_DEPTH                                           = 3;

  { The maximum number of terms in a compound SELECT statement. }
  SQLITE_LIMIT_COMPOUND_SELECT                                      = 4;

  { The maximum number of instructions in a virtual machine program used to 
    implement an SQL statement. If sqlite3_prepare_v2() or the equivalent tries 
    to allocate space for more than this many opcodes in a single prepared 
    statement, an SQLITE_NOMEM error is returned. }
  SQLITE_LIMIT_VDBE_OP                                              = 5;

  { The maximum number of arguments on a function. }
  SQLITE_LIMIT_FUNCTION_ARG                                         = 6;

  { The maximum number of attached databases. }
  SQLITE_LIMIT_ATTACHED                                             = 7;

  { The maximum length of the pattern argument to the LIKE or GLOB operators. }
  SQLITE_LIMIT_LIKE_PATTERN_LENGTH                                  = 8;

  { The maximum index number of any parameter in an SQL statement. }
  SQLITE_LIMIT_VARIABLE_NUMBER                                      = 9;

  { The maximum depth of recursion for triggers. }
  SQLITE_LIMIT_TRIGGER_DEPTH                                        = 10;

  { The maximum number of auxiliary worker threads that a single prepared 
    statement may start. }
  SQLITE_LIMIT_WORKER_THREADS                                       = 11;

  { These constants define various flags that can be passed into "prepFlags" 
    parameter of the sqlite3_prepare_v3() and sqlite3_prepare16_v3() 
    interfaces. }
  
  { The SQLITE_PREPARE_PERSISTENT flag is a hint to the query planner that the 
    prepared statement will be retained for a long time and probably reused many 
    times. Without this flag, sqlite3_prepare_v3() and sqlite3_prepare16_v3() 
    assume that the prepared statement will be used just once or at most a few 
    times and then destroyed using sqlite3_finalize() relatively soon. The 
    current implementation acts on this hint by avoiding the use of lookaside 
    memory so as not to deplete the limited store of lookaside memory. Future 
    versions of SQLite may act on this hint differently. }
  SQLITE_PREPARE_PERSISTENT                                         = $01;

  { The SQLITE_PREPARE_NORMALIZE flag is a no-op. This flag used to be required 
    for any prepared statement that wanted to use the sqlite3_normalized_sql() 
    interface. However, the sqlite3_normalized_sql() interface is now available 
    to all prepared statements, regardless of whether or not they use this 
    flag. }
  SQLITE_PREPARE_NORMALIZE                                          = $02;

  { The SQLITE_PREPARE_NO_VTAB flag causes the SQL compiler to return an error 
    (error code SQLITE_ERROR) if the statement uses any virtual tables. }
  SQLITE_PREPARE_NO_VTAB                                            = $04;

  { Every value in SQLite has one of five fundamental datatypes:

    64-bit signed integer
    64-bit IEEE floating point number
    string
    BLOB
    NULL 

    These constants are codes for each of those types.

    Note that the SQLITE_TEXT constant was also used in SQLite version 2 for a 
    completely different meaning. Software that links against both SQLite 
    version 2 and SQLite version 3 should use SQLITE3_TEXT, not SQLITE_TEXT. }
  SQLITE_INTEGER                                                      = 1;
  SQLITE_FLOAT                                                        = 2;
  SQLITE_BLOB                                                         = 4;
  SQLITE_NULL                                                         = 5;
  SQLITE_TEXT                                                         = 3;
  SQLITE3_TEXT                                                        = 3;

  { These constant define integer codes that represent the various text 
    encodings supported by SQLite. }
  SQLITE_UTF8          { IMP: R-37514-35566 }                         = 1;
  SQLITE_UTF16LE       { IMP: R-03371-37637 }                         = 2;
  SQLITE_UTF16BE       { IMP: R-51971-34154 }                         = 3;
  SQLITE_UTF16         { Use native byte order }                      = 4;
  SQLITE_ANY           { Deprecated }                                 = 5;
  SQLITE_UTF16_ALIGNED { sqlite3_create_collation only }              = 8;

  { These constants may be ORed together with the preferred text encoding as the 
    fourth argument to sqlite3_create_function(), sqlite3_create_function16(), 
    or sqlite3_create_function_v2(). }

  { The SQLITE_DETERMINISTIC flag means that the new function always gives the 
    same output when the input parameters are the same. The abs() function is 
    deterministic, for example, but randomblob() is not. Functions must be 
    deterministic in order to be used in certain contexts such as with the WHERE 
    clause of partial indexes or in generated columns. SQLite might also 
    optimize deterministic functions by factoring them out of inner loops. }
  SQLITE_DETERMINISTIC                                             = $000000800;

  { The SQLITE_DIRECTONLY flag means that the function may only be invoked from 
    top-level SQL, and cannot be used in VIEWs or TRIGGERs nor in schema 
    structures such as CHECK constraints, DEFAULT clauses, expression indexes, 
    partial indexes, or generated columns. The SQLITE_DIRECTONLY flags is a 
    security feature which is recommended for all application-defined SQL 
    functions, and especially for functions that have side-effects or that could 
    potentially leak sensitive information. }
  SQLITE_DIRECTONLY                                                = $000080000;

  { The SQLITE_SUBTYPE flag indicates to SQLite that a function may call 
    sqlite3_value_subtype() to inspect the sub-types of its arguments. 
    Specifying this flag makes no difference for scalar or aggregate user 
    functions. However, if it is not specified for a user-defined window 
    function, then any sub-types belonging to arguments passed to the window 
    function may be discarded before the window function is called (i.e. 
    sqlite3_value_subtype() will always return 0). }
  SQLITE_SUBTYPE                                                   = $000100000;

  { The SQLITE_INNOCUOUS flag means that the function is unlikely to cause 
    problems even if misused. An innocuous function should have no side effects 
    and should not depend on any values other than its input parameters. The 
    abs() function is an example of an innocuous function. The load_extension() 
    SQL function is not innocuous because of its side effects.

    SQLITE_INNOCUOUS is similar to SQLITE_DETERMINISTIC, but is not exactly the 
    same. The random() function is an example of a function that is innocuous 
    but not deterministic.

    Some heightened security settings (SQLITE_DBCONFIG_TRUSTED_SCHEMA and PRAGMA 
    trusted_schema=OFF) disable the use of SQL functions inside views and 
    triggers and in schema structures such as CHECK constraints, DEFAULT 
    clauses, expression indexes, partial indexes, and generated columns unless 
    the function is tagged with SQLITE_INNOCUOUS. Most built-in functions are 
    innocuous. Developers are advised to avoid using the SQLITE_INNOCUOUS flag 
    for application-defined functions unless the function has been carefully 
    audited and found to be free of potentially security-adverse side-effects 
    and information-leaks. }
  SQLITE_INNOCUOUS                                                 = $000200000;

  { These are special values for the destructor that is passed in as the final 
    argument to routines like sqlite3_result_blob(). If the destructor argument 
    is SQLITE_STATIC, it means that the content pointer is constant and will 
    never change. It does not need to be destroyed. The SQLITE_TRANSIENT value 
    means that the content will likely change in the near future and that SQLite 
    should make its own private copy of the content before returning. }
  SQLITE_STATIC                                                   = Pointer(0);
  SQLITE_TRANSIENT                                                = Pointer(-1);

  { These macros are only available on Windows. They define the allowed values 
    for the type argument to the sqlite3_win32_set_directory interface. }
  SQLITE_WIN32_DATA_DIRECTORY_TYPE                                     = 1;
  SQLITE_WIN32_TEMP_DIRECTORY_TYPE                                     = 2;

  { Virtual table implementations are allowed to set the 
    sqlite3_index_info.idxFlags field to some combination of these bits. }
  SQLITE_INDEX_SCAN_UNIQUE                                              = 1;

  { These macros define the allowed values for the 
    sqlite3_index_info.aConstraint[].op field. Each value represents an operator 
    that is part of a constraint term in the wHERE clause of a query that uses a 
    virtual table. }
  SQLITE_INDEX_CONSTRAINT_EQ                                            = 2;
  SQLITE_INDEX_CONSTRAINT_GT                                            = 4;
  SQLITE_INDEX_CONSTRAINT_LE                                            = 8;
  SQLITE_INDEX_CONSTRAINT_LT                                            = 16;
  SQLITE_INDEX_CONSTRAINT_GE                                            = 32;
  SQLITE_INDEX_CONSTRAINT_MATCH                                         = 64;
  SQLITE_INDEX_CONSTRAINT_LIKE                                          = 65;
  SQLITE_INDEX_CONSTRAINT_GLOB                                          = 66;
  SQLITE_INDEX_CONSTRAINT_REGEXP                                        = 67;
  SQLITE_INDEX_CONSTRAINT_NE                                            = 68;
  SQLITE_INDEX_CONSTRAINT_ISNOT                                         = 69;
  SQLITE_INDEX_CONSTRAINT_ISNOTNULL                                     = 70;
  SQLITE_INDEX_CONSTRAINT_ISNULL                                        = 71;
  SQLITE_INDEX_CONSTRAINT_IS                                            = 72;
  SQLITE_INDEX_CONSTRAINT_FUNCTION                                      = 150;

  { The sqlite3_mutex_alloc() interface takes a single argument which is one of 
    these integer constants.

    The set of static mutexes may change from one SQLite release to the next. 
    Applications that override the built-in mutex logic must be prepared to 
    accommodate additional static mutexes. }
  SQLITE_MUTEX_FAST                                                     = 0;
  SQLITE_MUTEX_RECURSIVE                                                = 1;
  SQLITE_MUTEX_STATIC_MAIN                                              = 2;
  SQLITE_MUTEX_STATIC_MEM           { sqlite3_malloc() }                = 3;
  SQLITE_MUTEX_STATIC_MEM2          { NOT USED }                        = 4;
  SQLITE_MUTEX_STATIC_OPEN          { sqlite3BtreeOpen() }              = 4;
  SQLITE_MUTEX_STATIC_PRNG          { sqlite3_randomness() }            = 5;
  SQLITE_MUTEX_STATIC_LRU           { lru page list }                   = 6;
  SQLITE_MUTEX_STATIC_LRU2          { NOT USED }                        = 7;
  SQLITE_MUTEX_STATIC_PMEM          { sqlite3PageMalloc() }             = 7;
  SQLITE_MUTEX_STATIC_APP1          { For use by application }          = 8;
  SQLITE_MUTEX_STATIC_APP2          { For use by application }          = 9;
  SQLITE_MUTEX_STATIC_APP3          { For use by application }          = 10;
  SQLITE_MUTEX_STATIC_VFS1          { For use by built-in VFS }         = 11;
  SQLITE_MUTEX_STATIC_VFS2          { For use by extension VFS }        = 12;
  SQLITE_MUTEX_STATIC_VFS3          { For use by application VFS }      = 13;

  { Legacy compatibility: }
  SQLITE_MUTEX_STATIC_MASTER                                            = 2;

  { These constants are the valid operation code parameters used as the first 
    argument to sqlite3_test_control().

    These parameters and their meanings are subject to change without notice. 
    These values are for testing purposes only. Applications should not use any 
    of these parameters or the sqlite3_test_control() interface. }
  SQLITE_TESTCTRL_FIRST                                                 = 5;
  SQLITE_TESTCTRL_PRNG_SAVE                                             = 5;
  SQLITE_TESTCTRL_PRNG_RESTORE                                          = 6;
  SQLITE_TESTCTRL_PRNG_RESET        { NOT USED }                        = 7;
  SQLITE_TESTCTRL_BITVEC_TEST                                           = 8;
  SQLITE_TESTCTRL_FAULT_INSTALL                                         = 9;
  SQLITE_TESTCTRL_BENIGN_MALLOC_HOOKS                                   = 10;
  SQLITE_TESTCTRL_PENDING_BYTE                                          = 11;
  SQLITE_TESTCTRL_ASSERT                                                = 12;
  SQLITE_TESTCTRL_ALWAYS                                                = 13;
  SQLITE_TESTCTRL_RESERVE           { NOT USED }                        = 14;
  SQLITE_TESTCTRL_OPTIMIZATIONS                                         = 15;
  SQLITE_TESTCTRL_ISKEYWORD         { NOT USED }                        = 16;
  SQLITE_TESTCTRL_SCRATCHMALLOC     { NOT USED }                        = 17;
  SQLITE_TESTCTRL_INTERNAL_FUNCTIONS                                    = 17;
  SQLITE_TESTCTRL_LOCALTIME_FAULT                                       = 18;
  SQLITE_TESTCTRL_EXPLAIN_STMT      { NOT USED }                        = 19;
  SQLITE_TESTCTRL_ONCE_RESET_THRESHOLD                                  = 19;
  SQLITE_TESTCTRL_NEVER_CORRUPT                                         = 20;
  SQLITE_TESTCTRL_VDBE_COVERAGE                                         = 21;
  SQLITE_TESTCTRL_BYTEORDER                                             = 22;
  SQLITE_TESTCTRL_ISINIT                                                = 23;
  SQLITE_TESTCTRL_SORTER_MMAP                                           = 24;
  SQLITE_TESTCTRL_IMPOSTER                                              = 25;
  SQLITE_TESTCTRL_PARSER_COVERAGE                                       = 26;
  SQLITE_TESTCTRL_RESULT_INTREAL                                        = 27;
  SQLITE_TESTCTRL_PRNG_SEED                                             = 28;
  SQLITE_TESTCTRL_EXTRA_SCHEMA_CHECKS                                   = 29;
  SQLITE_TESTCTRL_LAST              { Largest TESTCTRL }                = 29;

  { These integer constants designate various run-time status parameters that 
    can be returned by sqlite3_status(). }
  
  { This parameter is the current amount of memory checked out using 
    sqlite3_malloc(), either directly or indirectly. The figure includes calls 
    made to sqlite3_malloc() by the application and internal memory usage by the 
    SQLite library. Auxiliary page-cache memory controlled by 
    SQLITE_CONFIG_PAGECACHE is not included in this parameter. The amount 
    returned is the sum of the allocation sizes as reported by the xSize method 
    in sqlite3_mem_methods. }
  SQLITE_STATUS_MEMORY_USED                                             = 0;

  { This parameter returns the number of pages used out of the pagecache memory 
    allocator that was configured using SQLITE_CONFIG_PAGECACHE. The value 
    returned is in pages, not in bytes. }
  SQLITE_STATUS_PAGECACHE_USED                                          = 1;

  { This parameter returns the number of bytes of page cache allocation which 
    could not be satisfied by the SQLITE_CONFIG_PAGECACHE buffer and where 
    forced to overflow to sqlite3_malloc(). The returned value includes 
    allocations that overflowed because they where too large (they were larger 
    than the "sz" parameter to SQLITE_CONFIG_PAGECACHE) and allocations that 
    overflowed because no space was left in the page cache. }
  SQLITE_STATUS_PAGECACHE_OVERFLOW                                      = 2;

  SQLITE_STATUS_SCRATCH_USED        { NOT USED }                        = 3;
  SQLITE_STATUS_SCRATCH_OVERFLOW    { NOT USED }                        = 4;

  { This parameter records the largest memory allocation request handed to 
    sqlite3_malloc() or sqlite3_realloc() (or their internal equivalents). Only 
    the value returned in the *pHighwater parameter to sqlite3_status() is of 
    interest. The value written into the *pCurrent parameter is undefined. }
  SQLITE_STATUS_MALLOC_SIZE                                             = 5;

  { The *pHighwater parameter records the deepest parser stack. The *pCurrent 
    value is undefined. The *pHighwater value is only meaningful if SQLite is 
    compiled with YYTRACKMAXSTACKDEPTH. }
  SQLITE_STATUS_PARSER_STACK                                            = 6;

  { This parameter records the largest memory allocation request handed to the 
    pagecache memory allocator. Only the value returned in the *pHighwater 
    parameter to sqlite3_status() is of interest. The value written into the 
    *pCurrent parameter is undefined. }
  SQLITE_STATUS_PAGECACHE_SIZE                                          = 7;

  SQLITE_STATUS_SCRATCH_SIZE        { NOT USED }                        = 8;

  { This parameter records the number of separate memory allocations currently 
    checked out. }
  SQLITE_STATUS_MALLOC_COUNT                                            = 9;

  { These constants are the available integer "verbs" that can be passed as the 
    second argument to the sqlite3_db_status() interface.

    New verbs may be added in future releases of SQLite. Existing verbs might be 
    discontinued. Applications should check the return code from 
    sqlite3_db_status() to make sure that the call worked. The 
    sqlite3_db_status() interface will return a non-zero error code if a 
    discontinued or unsupported verb is invoked. }
  
  { This parameter returns the number of lookaside memory slots currently 
    checked out. }
  SQLITE_DBSTATUS_LOOKASIDE_USED                                        = 0;

  { This parameter returns the approximate number of bytes of heap memory used 
    by all pager caches associated with the database connection. The highwater 
    mark associated with SQLITE_DBSTATUS_CACHE_USED is always 0. }
  SQLITE_DBSTATUS_CACHE_USED                                            = 1;

  { This parameter returns the approximate number of bytes of heap memory used 
    to store the schema for all databases associated with the connection - main, 
    temp, and any ATTACH-ed databases. The full amount of memory used by the 
    schemas is reported, even if the schema memory is shared with other database 
    connections due to shared cache mode being enabled. The highwater mark 
    associated with SQLITE_DBSTATUS_SCHEMA_USED is always 0. }
  SQLITE_DBSTATUS_SCHEMA_USED                                           = 2;

  { This parameter returns the approximate number of bytes of heap and lookaside 
    memory used by all prepared statements associated with the database 
    connection. The highwater mark associated with SQLITE_DBSTATUS_STMT_USED is 
    always 0. }
  SQLITE_DBSTATUS_STMT_USED                                             = 3;

  { This parameter returns the number of malloc attempts that were satisfied 
    using lookaside memory. Only the high-water value is meaningful; the current 
    value is always zero. }
  SQLITE_DBSTATUS_LOOKASIDE_HIT                                         = 4;

  { This parameter returns the number malloc attempts that might have been 
    satisfied using lookaside memory but failed due to the amount of memory 
    requested being larger than the lookaside slot size. Only the high-water 
    value is meaningful; the current value is always zero. }
  SQLITE_DBSTATUS_LOOKASIDE_MISS_SIZE                                   = 5;

  { This parameter returns the number malloc attempts that might have been 
    satisfied using lookaside memory but failed due to all lookaside memory 
    already being in use. Only the high-water value is meaningful; the current 
    value is always zero. }
  SQLITE_DBSTATUS_LOOKASIDE_MISS_FULL                                   = 6;

  { This parameter returns the number of pager cache hits that have occurred. 
    The highwater mark associated with SQLITE_DBSTATUS_CACHE_HIT is always 0. }
  SQLITE_DBSTATUS_CACHE_HIT                                             = 7;

  { This parameter returns the number of pager cache misses that have occurred. 
    The highwater mark associated with SQLITE_DBSTATUS_CACHE_MISS is always 0. }
  SQLITE_DBSTATUS_CACHE_MISS                                            = 8;

  { This parameter returns the number of dirty cache entries that have been 
    written to disk. Specifically, the number of pages written to the wal file 
    in wal mode databases, or the number of pages written to the database file 
    in rollback mode databases. Any pages written as part of transaction 
    rollback or database recovery operations are not included. If an IO or other 
    error occurs while writing a page to disk, the effect on subsequent 
    SQLITE_DBSTATUS_CACHE_WRITE requests is undefined. The highwater mark 
    associated with SQLITE_DBSTATUS_CACHE_WRITE is always 0. }
  SQLITE_DBSTATUS_CACHE_WRITE                                           = 9;

  { This parameter returns zero for the current value if and only if all foreign 
    key constraints (deferred or immediate) have been resolved. The highwater 
    mark is always 0. }
  SQLITE_DBSTATUS_DEFERRED_FKS                                          = 10;

  { This parameter is similar to DBSTATUS_CACHE_USED, except that if a pager 
    cache is shared between two or more connections the bytes of heap memory 
    used by that pager cache is divided evenly between the attached connections. 
    In other words, if none of the pager caches associated with the database 
    connection are shared, this request returns the same value as 
    DBSTATUS_CACHE_USED. Or, if one or more or the pager caches are shared, the 
    value returned by this call will be smaller than that returned by 
    DBSTATUS_CACHE_USED. The highwater mark associated with 
    SQLITE_DBSTATUS_CACHE_USED_SHARED is always 0. }
  SQLITE_DBSTATUS_CACHE_USED_SHARED                                     = 11;

  { This parameter returns the number of dirty cache entries that have been 
    written to disk in the middle of a transaction due to the page cache 
    overflowing. Transactions are more efficient if they are written to disk all 
    at once. When pages spill mid-transaction, that introduces additional 
    overhead. This parameter can be used help identify inefficiencies that can 
    be resolved by increasing the cache size. }
  SQLITE_DBSTATUS_CACHE_SPILL                                           = 12;

  SQLITE_DBSTATUS_MAX         { Largest defined DBSTATUS }              = 12;

  { These preprocessor macros define integer codes that name counter values 
    associated with the sqlite3_stmt_status() interface. }

  { This is the number of times that SQLite has stepped forward in a table as 
    part of a full table scan. Large numbers for this counter may indicate 
    opportunities for performance improvement through careful use of indices. }
  SQLITE_STMTSTATUS_FULLSCAN_STEP                                       = 1;

  { This is the number of sort operations that have occurred. A non-zero value 
    in this counter may indicate an opportunity to improvement performance 
    through careful use of indices. }
  SQLITE_STMTSTATUS_SORT                                                = 2;

  { This is the number of rows inserted into transient indices that were created 
    automatically in order to help joins run faster. A non-zero value in this 
    counter may indicate an opportunity to improvement performance by adding 
    permanent indices that do not need to be reinitialized each time the 
    statement is run. }
  SQLITE_STMTSTATUS_AUTOINDEX                                           = 3;

  { This is the number of virtual machine operations executed by the prepared 
    statement if that number is less than or equal to 2147483647. The number of 
    virtual machine operations can be used as a proxy for the total work done by 
    the prepared statement. If the number of virtual machine operations exceeds 
    2147483647 then the value returned by this statement status code is 
    undefined. }
  SQLITE_STMTSTATUS_VM_STEP                                             = 4;

  { This is the number of times that the prepare statement has been 
    automatically regenerated due to schema changes or changes to bound 
    parameters that might affect the query plan. }
  SQLITE_STMTSTATUS_REPREPARE                                           = 5;

  { This is the number of times that the prepared statement has been run. A 
    single "run" for the purposes of this counter is one or more calls to 
    sqlite3_step() followed by a call to sqlite3_reset(). The counter is 
    incremented on the first sqlite3_step() call of each cycle. }
  SQLITE_STMTSTATUS_RUN                                                 = 6;

  { This is the approximate number of bytes of heap memory used to store the 
    prepared statement. This value is not actually a counter, and so the 
    resetFlg parameter to sqlite3_stmt_status() is ignored when the opcode is 
    SQLITE_STMTSTATUS_MEMUSED. }
  SQLITE_STMTSTATUS_MEMUSED                                             = 99;

type
  PPPChar = ^PPChar;
  PPChar = ^PChar;
  PPointer = ^Pointer;
  
  psqlite3_int64 = ^sqlite3_int64;
  sqlite3_int64 = type Int64;

  psqlite3_uint64 = ^sqlite3_uint64;
  sqlite3_uint64 = type QWord;

  { Strutures forward declarations. }
  ppsqlite3 = ^psqlite3;
  psqlite3 = ^sqlite3;
  psqlite3_file = ^sqlite3_file;
  psqlite3_io_methods = ^sqlite3_io_methods;
  psqlite3_mutex = ^sqlite3_mutex;
  psqlite3_api_routines = ^sqlite3_api_routines;
  psqlite3_vfs = ^sqlite3_vfs;
  psqlite3_mem_methods = ^sqlite3_mem_methods;
  psqlite3_stmt = ^sqlite3_stmt;
  ppsqlite3_value = ^psqlite3_value;
  psqlite3_value = ^sqlite3_value;
  psqlite3_context = ^sqlite3_context;
  ppsqlite3_vtab = ^psqlite3_vtab;
  psqlite3_vtab = ^sqlite3_vtab;
  psqlite3_index_info = ^sqlite3_index_info;
  ppsqlite3_vtab_cursor = ^psqlite3_vtab_cursor;
  psqlite3_vtab_cursor = ^sqlite3_vtab_cursor;
  psqlite3_module = ^sqlite3_module;
  ppsqlite3_blob = ^psqlite3_blob;
  psqlite3_blob = ^sqlite3_blob;
  psqlite3_mutex_methods = ^sqlite3_mutex_methods;
  psqlite3_str = ^sqlite3_str;
  psqlite3_pcache = ^sqlite3_pcache;
  psqlite3_pcache_page = ^sqlite3_pcache_page;
  psqlite3_pcache_methods2 = ^sqlite3_pcache_methods2;
  psqlite3_pcache_methods = ^sqlite3_pcache_methods;
  psqlite3_backup = ^sqlite3_backup;

  { Callbacks. }
  sqlite3_callback = function(pArg : Pointer; nCol : Integer; azVals : PPChar;
    azCols : PPChar) : Integer of object;

  sqlite3_syscall_ptr = procedure of object;
  sqlite3_destructor_type = procedure (ptr : Pointer) of object;

  xBusy_callback = function (ptr : Pointer; invoked : Integer) : Integer of 
    object;
  xAuth_callback = function (pAuthArg : Pointer; action_code : Integer; 
    const zArg1 : PChar; const zArg2 : PChar; const zArg3 : PChar; const zArg4 :
    PChar) : Integer of object;
  xTrace_callback = procedure (statement : Pointer; const text : PChar) of
    object;
  xProfile_callback = procedure (statement : Pointer; const text : PChar; 
    estimate : sqlite3_uint64) of object;
  xCallback_callback = function (invoked : Cardinal; context : Pointer; depend1
    : Pointer; depend2 : Pointer) : Integer of object;
  xProgress_callback = function (pArg : Pointer) : Integer of object;
  xDel_calback = procedure (pPtr : Pointer) of object;
  xDestructor_callback = procedure (pPtr : Pointer) of object;
  xFunc_callback = procedure (context : psqlite3_context; argc : Integer; argv : 
    ppsqlite3_value) of object;
  xStep_callback = procedure (context : psqlite3_context; argc : Integer; argv :
    ppsqlite3_value) of object;
  xFinal_callback = procedure (context : psqlite3_context) of object;
  xDestroy_callback = procedure (ptr : Pointer) of object;
  xValue_callback = procedure (context : psqlite3_context) of object;
  xInverse_callback = procedure (context : psqlite3_context; argc : Integer;
    argv : ppsqlite3_value) of object;
  xDelete_callback = procedure (ptr : Pointer) of object;
  xCompare_callback = function (pArg : Pointer; nBytes1 : Integer; 
    const eTextRep1 : Pointer; nBytes2 : Integer; const eTextRep2 : Pointer) :
    Integer of object;
  xCollNeeded_callback = procedure (pArg : Pointer; db : psqlite3; eTextRep :
    Integer; const collation_name : PChar) of object;
  xCollNeeded16_callback = procedure (pArg : Pointer; db : psqlite3; eTextRep :
    Integer; const collation_name : Pointer) of object; 
  xCallback_callback = function (pArg : Pointer) : Integer of object; 
  xCallbackUpdateHook_callback = procedure (pArg : Pointer; invoked : Integer;
    database_name : PChar; table_name : PChar; rowid : sqlite3_int64) of object;
  xEntryPoint_callback = function (db : psqlite3; const pzErrMgs : PPChar; 
    const pThunk : psqlite3_api_routines) : Integer of object;
  xFunc_callback = procedure (context : psqlite3_context; argc : Integer; argv :
    ppsqlite3_value) of object;


  { Each open SQLite database is represented by a pointer to an instance of the 
    opaque structure named "sqlite3". It is useful to think of an sqlite3 
    pointer as an object. }
  sqlite3 = record
    
  end;

  { An sqlite3_file object represents an open file in the OS interface layer. 
    Individual OS interface implementations will want to subclass this object by 
    appending additional fields for their own use. The pMethods entry is a 
    pointer to an sqlite3_io_methods object that defines methods for performing 
    I/O operations on the open file. }
  sqlite3_file = record
    pMethods : psqlite3_io_methods;
  end;

  { Every file opened by the sqlite3_vfs.xOpen method populates an sqlite3_file 
    object (or, more commonly, a subclass of the sqlite3_file object) with a 
    pointer to an instance of this object. This object defines the methods used 
    to perform various operations against the open file represented by the 
    sqlite3_file object.

    If the sqlite3_vfs.xOpen method sets the sqlite3_file.pMethods element to a 
    non-NULL pointer, then the sqlite3_io_methods.xClose method may be invoked 
    even if the sqlite3_vfs.xOpen reported that it failed. The only way to 
    prevent a call to xClose following a failed sqlite3_vfs.xOpen is for the 
    sqlite3_vfs.xOpen to set the sqlite3_file.pMethods element to NULL.

    The flags argument to xSync may be one of SQLITE_SYNC_NORMAL or 
    SQLITE_SYNC_FULL. The first choice is the normal fsync(). The second choice 
    is a Mac OS X style fullsync. The SQLITE_SYNC_DATAONLY flag may be ORed in 
    to indicate that only the data of the file and not its inode needs to be 
    synced. 
    
    xLock() increases the lock. xUnlock() decreases the lock. The 
    xCheckReservedLock() method checks whether any database connection, either 
    in this process or in some other process, is holding a RESERVED, PENDING, or 
    EXCLUSIVE lock on the file. It returns true if such a lock exists and false 
    otherwise.

    The xFileControl() method is a generic interface that allows custom VFS 
    implementations to directly control an open file using the 
    sqlite3_file_control() interface. The second "op" argument is an integer 
    opcode. The third argument is a generic pointer intended to point to a 
    structure that may contain arguments or space in which to write return 
    values. Potential uses for xFileControl() might be functions to enable 
    blocking locks with timeouts, to change the locking strategy (for example to 
    use dot-file locks), to inquire about the status of a lock, or to break 
    stale locks. The SQLite core reserves all opcodes less than 100 for its own 
    use. A list of opcodes less than 100 is available. Applications that define 
    a custom xFileControl method should use opcodes greater than 100 to avoid 
    conflicts. VFS implementations should return SQLITE_NOTFOUND for file 
    control opcodes that they do not recognize.

    The xSectorSize() method returns the sector size of the device that 
    underlies the file. The sector size is the minimum write that can be 
    performed without disturbing other bytes in the file.

    The SQLITE_IOCAP_ATOMIC property means that all writes of any size are 
    atomic. The SQLITE_IOCAP_ATOMICnnn values mean that writes of blocks that 
    are nnn bytes in size and are aligned to an address which is an integer 
    multiple of nnn are atomic. The SQLITE_IOCAP_SAFE_APPEND value means that 
    when data is appended to a file, the data is appended first then the size of 
    the file is extended, never the other way around. The 
    SQLITE_IOCAP_SEQUENTIAL property means that information is written to disk 
    in the same order as calls to xWrite().

    If xRead() returns SQLITE_IOERR_SHORT_READ it must also fill in the unread 
    portions of the buffer with zeros. A VFS that fails to zero-fill short reads 
    might seem to work. However, failure to zero-fill short reads will 
    eventually lead to database corruption. }
  sqlite3_io_methods = record
    iVersion : Integer;
    xClose : function (pId : psqlite3_file) : Integer; cdecl;
    xRead : function (pId : psqlite3_file; pBuf : Pointer; iAmt : Integer;
      iOfst : sqlite3_int64) : Integer; cdecl;
    xWrite : function (pId : psqlite3_file; const pBuf : Pointer; iAmt : 
      Integer; iOfst : sqlite3_int64) : Integer; cdecl;
    xTruncate : function (pId : psqlite3_file; size : sqlite3_int64) : Integer;
      cdecl;
    xSync : function (pId : psqlite3_file; flags : Integer) : Integer; cdecl;
    xFileSize : function (pId : psqlite3_file; pSize : psqlite3_int64) : 
      Integer; cdecl;
    xLock : function (pId : psqlite3_file; lockType : Integer) : Integer; cdecl;
    xUnlock : function (pId : psqlite3_file; lockType : Integer) : Integer;
      cdecl;
    xCheckReservedLock : function (pId : psqlite3_file; pResOut : PInteger) :
      Integer; cdecl;
    xFileControl : function (pId : psqlite3_file; op : Integer; pArg : Pointer) 
      : Integer; cdecl;
    xSectorSize : function (pId : psqlite3_file) : Integer; cdecl;
    xDeviceCharacteristics : function (pId : psqlite3_file) : Integer; cdecl;
    { Methods above are valid for version 1 }
    xShmMap : function (pId : psqlite3_file; iPg : Integer; pgsz : Integer;
      bExtend : Integer; pp : PPointer) : Integer; cdecl;
    xShmLock : function (pId : psqlite3_file; offset : Integer; n : Integer;
      flags : Integer) : Integer; cdecl;
    xShmBarrier : function (pId : psqlite3_file) : Integer; cdecl;
    xShmUnmap : function (pId : psqlite3_file; deleteFlag : Integer) : Integer;
      cdecl;
    { Methods above are valid for version 2 }
    xFetch : function (pId : psqlite3_file; iOfst : sqlite3_int64; iAmt : 
      Integer; pp : PPointer) : Integer; cdecl;
    xUnfetch : function (pId : psqlite3_file; iOfst : sqlite3_int64; p : 
      Pointer) : Integer; cdecl;
    { Methods above are valid for version 3 }
    { Additional methods may be added in future releases }
  end;

  { The mutex module within SQLite defines sqlite3_mutex to be an abstract type 
    for a mutex object. The SQLite core never looks at the internal 
    representation of an sqlite3_mutex. It only deals with pointers to the 
    sqlite3_mutex object.

    Mutexes are created using sqlite3_mutex_alloc(). }
  sqlite3_mutex = record

  end;

  { A pointer to the opaque sqlite3_api_routines structure is passed as the 
    third parameter to entry points of loadable extensions. This structure must 
    be typedefed in order to work around compiler warnings on some platforms. }
  sqlite3_api_routines = record

  end;

  { An instance of the sqlite3_vfs object defines the interface between the 
    SQLite core and the underlying operating system. The "vfs" in the name of 
    the object stands for "virtual file system". See the VFS documentation for 
    further information.

    The VFS interface is sometimes extended by adding new methods onto the end. 
    Each time such an extension occurs, the iVersion field is incremented. The 
    iVersion value started out as 1 in SQLite version 3.5.0 on 2007-09-04, then 
    increased to 2 with SQLite version 3.7.0 on 2010-07-21, and then increased 
    to 3 with SQLite version 3.7.6 on 2011-04-12. Additional fields may be 
    appended to the sqlite3_vfs object and the iVersion value may increase again 
    in future versions of SQLite. Note that due to an oversight, the structure 
    of the sqlite3_vfs object changed in the transition from SQLite version 
    3.5.9 to version 3.6.0 on 2008-07-16 and yet the iVersion field was not 
    increased. }
  sqlite3_vfs = record
    iVersion : Integer;       { Structure version number (currently 3) }
    szOsFile : Integer;       { Size of subclassed sqlite3_file }
    mxPathname : Integer;     { Maximum file pathname length }
    pNext : psqlite3_vfs;     { Next registered VFS }
    zName : PChar;            { Name of this virtual file system }
    pAppData : Pointer;       { Pointer to application-specific data }
    xOpen : function (pVfs : psqlite3_vfs; const zName : PChar; pFile :
      psqlite3_file; flags : Integer; pOutFlags : PInteger) : Integer; cdecl;
    xDelete : function (pVfs : psqlite3_vfs; const zName : PChar; syncDir :
      Integer) : Integer; cdecl;
    xAccess : function (pVfs : psqlite3_vfs; const zName : PChar; flags : 
      Integer; pResOut : PInteger) : Integer; cdecl;
    xFullPathname : function (pVfs : psqlite3_vfs; const zName : PChar; nOut :
      Integer; zOut : PChar) : Integer; cdecl;
    xDlOpen : function (pVfs : psqlite3_vfs; const zFilename : PChar) :
      Pointer; cdecl;
    xDlError : procedure (pVfs : psqlite3_vfs; nByte : Integer; zErrMgs : 
      PChar); cdecl;
    xDlSym : function (pVfs : psqlite3_vfs; pHandle : Pointer; const zSymbol :
      PChar) : Pointer; cdecl;
    xDlClose : procedure (pVfs : psqlite3_vfs; pHandle : Pointer); cdecl;
    xRandomness : function (pVfs : psqlite3_vfs; nByte : Integer; zOut : PChar) 
      : Integer; cdecl;
    xSleep : function (pVfs : psqlite3_vfs; microseconds : Integer) : Integer;
      cdecl;
    xCurrentTime : function (pVfs : psqlite3_vfs; pTimeout : PDouble) : Integer;
      cdecl;
    xGetLastError : function (pVfs : psqlite3_vfs; nBuf : Integer; zBuf : PChar)
      : Integer; cdecl;
    
    { The methods above are in version 1 of the sqlite_vfs object definition. 
      Those that follow are added in version 2 or later }
    xCurrentTimeInt64 : function (pVfs : psqlite3_vfs; pTimeOut : 
      psqlite3_int64) : Integer; cdecl;
    
    { The methods above are in versions 1 and 2 of the sqlite_vfs object. Those 
      below are for version 3 and greater. }
    xSetSystemCall : function (pVfs : psqlite3_vfs; const zName : PChar; 
      pNewFunc : sqlite3_syscall_ptr) : Integer; cdecl;
    xGetSystemCall : function (pVfs : psqlite3_vfs; const zName : PChar) :
      sqlite3_syscall_ptr; cdecl;
    xNextSystemCall : function (pVfs : psqlite3_vfs; const zName : PChar) :
      PChar; cdecl;

    { The methods above are in versions 1 through 3 of the sqlite_vfs object. 
      New fields may be appended in future versions. The iVersion value will 
      increment whenever this happens. }
  end;

  { An instance of this object defines the interface between SQLite and 
    low-level memory allocation routines.

    This object is used in only one place in the SQLite interface. A pointer to 
    an instance of this object is the argument to sqlite3_config() when the 
    configuration option is SQLITE_CONFIG_MALLOC or SQLITE_CONFIG_GETMALLOC. By 
    creating an instance of this object and passing it to 
    sqlite3_config(SQLITE_CONFIG_MALLOC) during configuration, an application 
    can specify an alternative memory allocation subsystem for SQLite to use for 
    all of its dynamic memory needs.

    Note that SQLite comes with several built-in memory allocators that are 
    perfectly adequate for the overwhelming majority of applications and that 
    this object is only useful to a tiny minority of applications with 
    specialized memory allocation requirements. This object is also used during 
    testing of SQLite in order to specify an alternative memory allocator that 
    simulates memory out-of-memory conditions in order to verify that SQLite 
    recovers gracefully from such conditions.

    The xMalloc, xRealloc, and xFree methods must work like the malloc(), 
    realloc() and free() functions from the standard C library. SQLite 
    guarantees that the second argument to xRealloc is always a value returned 
    by a prior call to xRoundup.

    xSize should return the allocated size of a memory allocation previously 
    obtained from xMalloc or xRealloc. The allocated size is always at least as 
    big as the requested size but may be larger.

    The xRoundup method returns what would be the allocated size of a memory 
    allocation given a particular requested size. Most memory allocators round 
    up memory allocations at least to the next multiple of 8. Some allocators 
    round up to a larger multiple or to a power of 2. Every memory allocation 
    request coming in through sqlite3_malloc() or sqlite3_realloc() first calls 
    xRoundup. If xRoundup returns 0, that causes the corresponding memory 
    allocation to fail.

    The xInit method initializes the memory allocator. For example, it might 
    allocate any required mutexes or initialize internal data structures. The 
    xShutdown method is invoked (indirectly) by sqlite3_shutdown() and should 
    deallocate any resources acquired by xInit. The pAppData pointer is used as 
    the only parameter to xInit and xShutdown.

    SQLite holds the SQLITE_MUTEX_STATIC_MAIN mutex when it invokes the xInit 
    method, so the xInit method need not be threadsafe. The xShutdown method is 
    only called from sqlite3_shutdown() so it does not need to be threadsafe 
    either. For all other methods, SQLite holds the SQLITE_MUTEX_STATIC_MEM 
    mutex as long as the SQLITE_CONFIG_MEMSTATUS configuration option is turned 
    on (which it is by default) and so the methods are automatically serialized. 
    However, if SQLITE_CONFIG_MEMSTATUS is disabled, then the other methods must 
    be threadsafe or else make their own arrangements for serialization.

    SQLite will never invoke xInit() more than once without an intervening call 
    to xShutdown(). }
  sqlite3_mem_methods = record
    { Memory allocation function }
    xMalloc : function (nFull : Integer) : Pointer; cdecl;
    { Free a prior allocation }
    xFree : procedure (ptr : Pointer); cdecl;
    { Resize an allocation }
    xRealloc : function (pOld : Pointer; nNew : Integer) : Pointer; cdecl;
    { Return the size of an allocation }
    xSize : function (ptr : Pointer) : Integer; cdecl;
    { Round up request size to allocation size }
    xRoundup : function (nBytes : Integer) : Integer; cdecl;
    { Initialize the memory allocator }
    xInit : function (ptr : Pointer) : Integer; cdecl;
    { Deinitialize the memory allocator }
    xShutdown : procedure (ptr : Pointer); cdecl;
    { Argument to xInit() and xShutdown() }
    pAppData : Pointer;
  end;

  { An instance of this object represents a single SQL statement that has been 
    compiled into binary form and is ready to be evaluated.

    Think of each SQL statement as a separate computer program. The original SQL 
    text is source code. A prepared statement object is the compiled object 
    code. All SQL must be converted into a prepared statement before it can be 
    run. }
  sqlite3_stmt = record

  end;

  { SQLite uses the sqlite3_value object to represent all values that can be 
    stored in a database table. SQLite uses dynamic typing for the values it 
    stores. Values stored in sqlite3_value objects can be integers, floating 
    point values, strings, BLOBs, or NULL.

    An sqlite3_value object may be either "protected" or "unprotected". Some 
    interfaces require a protected sqlite3_value. Other interfaces will accept 
    either a protected or an unprotected sqlite3_value. Every interface that 
    accepts sqlite3_value arguments specifies whether or not it requires a 
    protected sqlite3_value. The sqlite3_value_dup() interface can be used to 
    construct a new protected sqlite3_value from an unprotected sqlite3_value.

    The terms "protected" and "unprotected" refer to whether or not a mutex is 
    held. An internal mutex is held for a protected sqlite3_value object but no 
    mutex is held for an unprotected sqlite3_value object. If SQLite is compiled 
    to be single-threaded (with SQLITE_THREADSAFE=0 and with 
    sqlite3_threadsafe() returning 0) or if SQLite is run in one of reduced 
    mutex modes SQLITE_CONFIG_SINGLETHREAD or SQLITE_CONFIG_MULTITHREAD then 
    there is no distinction between protected and unprotected sqlite3_value 
    objects and they can be used interchangeably. However, for maximum code 
    portability it is recommended that applications still make the distinction 
    between protected and unprotected sqlite3_value objects even when not 
    strictly required.

    The sqlite3_value objects that are passed as parameters into the 
    implementation of application-defined SQL functions are protected. The 
    sqlite3_value object returned by sqlite3_column_value() is unprotected. 
    Unprotected sqlite3_value objects may only be used as arguments to 
    sqlite3_result_value(), sqlite3_bind_value(), and sqlite3_value_dup(). }
  sqlite3_value = record

  end;

  { The context in which an SQL function executes is stored in an 
    sqlite3_context object. A pointer to an sqlite3_context object is always 
    first parameter to application-defined SQL functions. The 
    application-defined SQL function implementation will pass this pointer 
    through into calls to sqlite3_result(), sqlite3_aggregate_context(), 
    sqlite3_user_data(), sqlite3_context_db_handle(), sqlite3_get_auxdata(), 
    and/or sqlite3_set_auxdata(). }
  sqlite3_context = record

  end;

  { Every virtual table module implementation uses a subclass of this object to 
    describe a particular instance of the virtual table. Each subclass will be 
    tailored to the specific needs of the module implementation. The purpose of 
    this superclass is to define certain fields that are common to all module 
    implementations.

    Virtual tables methods can set an error message by assigning a string 
    obtained from sqlite3_mprintf() to zErrMsg. The method should take care that 
    any prior string is freed by a call to sqlite3_free() prior to assigning a 
    new string to zErrMsg. After the error message is delivered up to the client 
    application, the string will be automatically freed by sqlite3_free() and 
    the zErrMsg field will be zeroed. }
  sqlite3_vtab = record
    pModule : psqlite3_module;    { The module for this virtual table }
    nRef : Integer;               { Number of open cursors }
    zErrMsg : PChar;              { Error message from sqlite3_mprintf() }
  end;

  { The sqlite3_index_info structure and its substructures is used as part of 
    the virtual table interface to pass information into and receive the reply 
    from the xBestIndex method of a virtual table module. The fields under 
    **Inputs** are the inputs to xBestIndex and are read-only. xBestIndex 
    inserts its results into the **Outputs** fields.

    The aConstraint[] array records WHERE clause constraints of the form:

      column OP expr

    where OP is =, <, <=, >, or >=. The particular operator is stored in 
    aConstraint[].op using one of the SQLITE_INDEX_CONSTRAINT_ values. The index 
    of the column is stored in aConstraint[].iColumn. aConstraint[].usable is 
    TRUE if the expr on the right-hand side can be evaluated (and thus the 
    constraint is usable) and false if it cannot.

    The optimizer automatically inverts terms of the form "expr OP column" and 
    makes other simplifications to the WHERE clause in an attempt to get as many 
    WHERE clause terms into the form shown above as possible. The aConstraint[] 
    array only reports WHERE clause terms that are relevant to the particular 
    virtual table being queried.

    Information about the ORDER BY clause is stored in aOrderBy[]. Each term of 
    aOrderBy records a column of the ORDER BY clause.

    The colUsed field indicates which columns of the virtual table may be 
    required by the current scan. Virtual table columns are numbered from zero 
    in the order in which they appear within the CREATE TABLE statement passed 
    to sqlite3_declare_vtab(). For the first 63 columns (columns 0-62), the 
    corresponding bit is set within the colUsed mask if the column may be 
    required by SQLite. If the table has at least 64 columns and any column to 
    the right of the first 63 is required, then bit 63 of colUsed is also set. 
    In other words, column iCol may be required if the expression (colUsed & 
    ((sqlite3_uint64)1 << (iCol>=63 ? 63 : iCol))) evaluates to non-zero.

    The xBestIndex method must fill aConstraintUsage[] with information about 
    what parameters to pass to xFilter. If argvIndex>0 then the right-hand side 
    of the corresponding aConstraint[] is evaluated and becomes the argvIndex-th 
    entry in argv. If aConstraintUsage[].omit is true, then the constraint is 
    assumed to be fully handled by the virtual table and might not be checked 
    again by the byte code. The aConstraintUsage[].omit flag is an optimization 
    hint. When the omit flag is left in its default setting of false, the 
    constraint will always be checked separately in byte code. If the omit flag 
    is change to true, then the constraint may or may not be checked in byte 
    code. In other words, when the omit flag is true there is no guarantee that 
    the constraint will not be checked again using byte code.

    The idxNum and idxPtr values are recorded and passed into the xFilter 
    method. sqlite3_free() is used to free idxPtr if and only if 
    needToFreeIdxPtr is true.

    The orderByConsumed means that output from xFilter/xNext will occur in the 
    correct order to satisfy the ORDER BY clause so that no separate sorting 
    step is required.

    The estimatedCost value is an estimate of the cost of a particular strategy. 
    A cost of N indicates that the cost of the strategy is similar to a linear 
    scan of an SQLite table with N rows. A cost of log(N) indicates that the 
    expense of the operation is similar to that of a binary search on a unique 
    indexed field of an SQLite table with N rows.

    The estimatedRows value is an estimate of the number of rows that will be 
    returned by the strategy.

    The xBestIndex method may optionally populate the idxFlags field with a mask 
    of SQLITE_INDEX_SCAN_* flags. Currently there is only one such flag - 
    SQLITE_INDEX_SCAN_UNIQUE. If the xBestIndex method sets this flag, SQLite 
    assumes that the strategy may visit at most one row.

    Additionally, if xBestIndex sets the SQLITE_INDEX_SCAN_UNIQUE flag, then 
    SQLite also assumes that if a call to the xUpdate() method is made as part 
    of the same statement to delete or update a virtual table row and the 
    implementation returns SQLITE_CONSTRAINT, then there is no need to rollback 
    any database changes. In other words, if the xUpdate() returns 
    SQLITE_CONSTRAINT, the database contents must be exactly as they were before 
    xUpdate was called. By contrast, if SQLITE_INDEX_SCAN_UNIQUE is not set and 
    xUpdate returns SQLITE_CONSTRAINT, any database changes made by the xUpdate 
    method are automatically rolled back by SQLite.

    IMPORTANT: The estimatedRows field was added to the sqlite3_index_info 
    structure for SQLite version 3.8.2 (2013-12-06). If a virtual table 
    extension is used with an SQLite version earlier than 3.8.2, the results of 
    attempting to read or write the estimatedRows field are undefined (but are 
    likely to include crashing the application). The estimatedRows field should 
    therefore only be used if sqlite3_libversion_number() returns a value 
    greater than or equal to 3008002. Similarly, the idxFlags field was added 
    for version 3.9.0 (2015-10-14). It may therefore only be used if 
    sqlite3_libversion_number() returns a value greater than or equal to 
    3009000. }

  psqlite3_index_constraint = ^sqlite3_index_constraint;
  sqlite3_index_constraint = record
    iColumn : Integer;                { Column constrained.  -1 for ROWID }
    op : Byte;                        { Constraint operator }
    usable : Byte;                    { True if this constraint is usable }
    iTermOffset : Integer;            { Used internally - xBestIndex should 
                                        ignore }
  end;

  psqlite3_index_orderby = ^sqlite3_index_orderby;
  sqlite3_index_orderby = record
    iColumn : Integer;                { Column number }
    desc : Byte;                      { True for DESC.  False for ASC. }
  end;

  psqlite3_index_constraint_usage = ^sqlite3_index_constraint_usage;
  sqlite3_index_constraint_usage = record
    argvIndex : Integer;              { if >0, constraint is part of argv to 
                                        xFilter }
    omit : Byte;                      { Do not code a test for this constraint }
  end;

  sqlite3_index_info = record
    { Inputs }
    nConstraint : Integer;            { Number of entries in aConstraint }
    aConstarint : psqlite3_index_constraint; {Table of WHERE clause constraints}
    nOrderBy : Integer;               { Number of terms in the ORDER BY clause }
    aOrderBy : psqlite3_index_orderby;{ The ORDER BY clause }

    { Outputs }
    aConstraintUsage : psqlite3_index_constraint_usage;
    idxNum : Integer;                 { Number used to identify the index }
    idxStr : PChar;                   { String, possibly obtained from 
                                        sqlite3_malloc }
    needToFreeIdxStr : Integer;       {Free idxStr using sqlite3_free() if true}
    orderByConsumed : Integer;        { True if output is already ordered }
    estimatedCost : Double;           { Estimated cost of using this index }
    { Fields below are only available in SQLite 3.8.2 and later }
    estimatedRows : sqlite3_int64;    { Estimated number of rows returned }
    { Fields below are only available in SQLite 3.9.0 and later }
    idxFlags : Integer;               { Mask of SQLITE_INDEX_SCAN_* flags }
    { Fields below are only available in SQLite 3.10.0 and later }
    colUsed : sqlite3_uint64;         {Input: Mask of columns used by statement}
  end;

  { Every virtual table module implementation uses a subclass of the following 
    structure to describe cursors that point into the virtual table and are used 
    to loop through the virtual table. Cursors are created using the xOpen 
    method of the module and are destroyed by the xClose method. Cursors are 
    used by the xFilter, xNext, xEof, xColumn, and xRowid methods of the module. 
    Each module implementation will define the content of a cursor structure to 
    suit its own needs.

    This superclass exists in order to define fields of the cursor that are 
    common to all implementations. }
  sqlite3_vtab_cursor = record
    pVtab : psqlite3_vtab;            { Virtual table of this cursor }
  end;

  { This structure, sometimes called a "virtual table module", defines the 
    implementation of a virtual table. This structure consists mostly of methods 
    for the module.

    A virtual table module is created by filling in a persistent instance of 
    this structure and passing a pointer to that instance to 
    sqlite3_create_module() or sqlite3_create_module_v2(). The registration 
    remains valid until it is replaced by a different module or until the 
    database connection closes. The content of this structure must not change 
    while it is registered with any database connection. }
  sqlite3_module = record
    iVersion : Integer;
    xCreate : function (db : psqlite3; pAux : Pointer; argc : Integer; 
      const argv : PChar; ppVtab : ppsqlite3_vtab; pzErr : PPchar) : Integer; 
      cdecl;
    xConnect : function (db : psqlite3; pAux : Pointer; argc : Integer; 
      const argv : PChar; ppVtab : ppsqlite3_vtab; pzErr : PPChar) : Integer;
      cdecl;
    xBestIndex : function (pVTab : psqlite3_vtab; index_info : 
      psqlite3_index_info) : Integer; cdecl;
    xDisconnect : function (pVTab : psqlite3_vtab) : Integer; cdecl;
    xDestroy : function (pVTab : psqlite3_vtab) : Integer; cdecl;
    xOpen : function (pVTab : psqlite3_vtab; ppCursor : ppsqlite3_vtab_cursor) :
      Integer; cdecl;
    xClose : function (pCursor : psqlite3_vtab_cursor) : Integer; cdecl;
    xFilter : function (pCursor : psqlite3_vtab_cursor; idxNum : Integer;
      const idxStr : PChar; argc : Integer; argv : ppsqlite3_value) : Integer;
      cdecl;
    xNext : function (pCursor : psqlite3_vtab_cursor) : Integer; cdecl;
    xEof : function (pCursor : psqlite3_vtab_cursor) : Integer; cdecl;
    xColumn : function (pCursor : psqlite3_vtab_cursor; pContext :
      psqlite3_context; pOp : Integer) : Integer; cdecl;
    xRowid : function (pCursor : psqlite3_vtab_cursor; pRowid : sqlite3_int64) :
      Integer; cdecl;
    xUpdate : function (pVTab : psqlite3_vtab; nArg : Integer; apArg : 
      ppsqlite3_value; rowid : psqlite3_int64) : Integer; cdecl;
    xBegin : function (pVTab : psqlite3_vtab) : Integer; cdecl;
    xSync : function (pVTab : psqlite3_vtab) : Integer; cdecl;
    xCommit : function (pVTab : psqlite3_vtab) : Integer; cdecl;
    xRollback : function (pVTab : psqlite3_vtab) : Integer; cdecl;
    xFindFunction : function (pVTab : psqlite3_vtab; nArg : Integer; 
      const zName : PChar; pxFunc : xFunc_callback; ppArg : PPointer) : Integer;
      cdecl;
    xRename : function (pVTab : psqlite3_vtab; const zName : PChar) : Integer;
      cdecl;
    { The methods above are in version 1 of the sqlite_module object. Those
      below are for version 2 and greater. }
    xSavepoint : function (pVTab : psqlite3_vtab; iSvpt : Integer) : Integer;
      cdecl;
    xRelease : function (pVTab : psqlite3_vtab; iSvpt : Integer) : Integer;
      cdecl;
    xRollbackTo : function (pVTab : psqlite3_vtab; iSvpt : Integer) : Integer;
      cdecl;
    { The methods above are in versions 1 and 2 of the sqlite_module object.
      Those below are for version 3 and greater. }
    xShadowName : function (const zName : PChar) : Integer; cdecl;
  end;

  { An instance of this object represents an open BLOB on which incremental BLOB 
    I/O can be performed. Objects of this type are created by 
    sqlite3_blob_open() and destroyed by sqlite3_blob_close(). 
    The sqlite3_blob_read() and sqlite3_blob_write() interfaces can be used to 
    read or write small subsections of the BLOB. The sqlite3_blob_bytes() 
    interface returns the size of the BLOB in bytes. }
  sqlite3_blob = record

  end;

  { An instance of this structure defines the low-level routines used to 
    allocate and use mutexes.

    Usually, the default mutex implementations provided by SQLite are 
    sufficient, however the application has the option of substituting a custom 
    implementation for specialized deployments or systems for which SQLite does 
    not provide a suitable implementation. In this case, the application creates 
    and populates an instance of this structure to pass to sqlite3_config() 
    along with the SQLITE_CONFIG_MUTEX option. Additionally, an instance of this 
    structure can be used as an output variable when querying the system for the 
    current mutex implementation, using the SQLITE_CONFIG_GETMUTEX option.

    The xMutexInit method defined by this structure is invoked as part of system 
    initialization by the sqlite3_initialize() function. The xMutexInit routine 
    is called by SQLite exactly once for each effective call to 
    sqlite3_initialize().

    The xMutexEnd method defined by this structure is invoked as part of system 
    shutdown by the sqlite3_shutdown() function. The implementation of this 
    method is expected to release all outstanding resources obtained by the 
    mutex methods implementation, especially those obtained by the xMutexInit 
    method. The xMutexEnd() interface is invoked exactly once for each call to 
    sqlite3_shutdown().

    The remaining seven methods defined by this structure (xMutexAlloc, 
    xMutexFree, xMutexEnter, xMutexTry, xMutexLeave, xMutexHeld and 
    xMutexNotheld) implement the following interfaces (respectively):

      sqlite3_mutex_alloc()
      sqlite3_mutex_free()
      sqlite3_mutex_enter()
      sqlite3_mutex_try()
      sqlite3_mutex_leave()
      sqlite3_mutex_held()
      sqlite3_mutex_notheld()

    The only difference is that the public sqlite3_XXX functions enumerated 
    above silently ignore any invocations that pass a NULL pointer instead of a 
    valid mutex handle. The implementations of the methods defined by this 
    structure are not required to handle this case. The results of passing a 
    NULL pointer instead of a valid mutex handle are undefined (i.e. it is 
    acceptable to provide an implementation that segfaults if it is passed a 
    NULL pointer).

    The xMutexInit() method must be threadsafe. It must be harmless to invoke 
    xMutexInit() multiple times within the same process and without intervening 
    calls to xMutexEnd(). Second and subsequent calls to xMutexInit() must be 
    no-ops.

    xMutexInit() must not use SQLite memory allocation (sqlite3_malloc() and its 
    associates). Similarly, xMutexAlloc() must not use SQLite memory allocation 
    for a static mutex. However xMutexAlloc() may use SQLite memory allocation 
    for a fast or recursive mutex.

    SQLite will invoke the xMutexEnd() method when sqlite3_shutdown() is called, 
    but only if the prior call to xMutexInit returned SQLITE_OK. If xMutexInit 
    fails in any way, it is expected to clean up after itself prior to 
    returning. }
  sqlite3_mutex_methods = record
    xMutexInit : function : Integer; cdecl;
    xMutexEnd : function : Integer; cdecl;
    xMutexAlloc : function (id : Integer) : psqlite3_mutex; cdecl;
    xMutexFree : procedure (p : psqlite3_mutex); cdecl;
    xMutexEnter : procedure (p : psqlite3_mutex); cdecl;
    xMutexTry : function (p : psqlite3_mutex) : Integer; cdecl;
    xMutexLeave : procedure (p : psqlite3_mutex); cdecl;
    xMutexHeld : function (p : psqlite3_mutex) : Integer; cdecl;
    xMutexNotheld : function (p : psqlite3_mutex) : Integer; cdecl;
  end;

  { An instance of the sqlite3_str object contains a dynamically-sized string 
    under construction.

    The lifecycle of an sqlite3_str object is as follows:

      The sqlite3_str object is created using sqlite3_str_new().
      Text is appended to the sqlite3_str object using various methods, such as 
        sqlite3_str_appendf().
      The sqlite3_str object is destroyed and the string it created is returned 
        using the sqlite3_str_finish() interface. }
  sqlite3_str = record

  end;

  { The sqlite3_pcache type is opaque. It is implemented by the pluggable 
    module. The SQLite core has no knowledge of its size or internal structure 
    and never deals with the sqlite3_pcache object except by holding and passing 
    pointers to the object. }
  sqlite3_pcache = record

  end;

  { The sqlite3_pcache_page object represents a single page in the page cache. 
    The page cache will allocate instances of this object. Various methods of 
    the page cache use pointers to instances of this object as parameters or as 
    their return value. }
  sqlite3_pcache_page = record
    pBuf : Pointer;               { The content of the page }
    pExtra : Pointer;             { Extra information associated with the page }
  end;

  { The sqlite3_config(SQLITE_CONFIG_PCACHE2, ...) interface can register an 
    alternative page cache implementation by passing in an instance of the 
    sqlite3_pcache_methods2 structure. In many applications, most of the heap 
    memory allocated by SQLite is used for the page cache. By implementing a 
    custom page cache using this API, an application can better control the 
    amount of memory consumed by SQLite, the way in which that memory is 
    allocated and released, and the policies used to determine exactly which 
    parts of a database file are cached and for how long.

    The alternative page cache mechanism is an extreme measure that is only 
    needed by the most demanding applications. The built-in page cache is 
    recommended for most uses.

    The contents of the sqlite3_pcache_methods2 structure are copied to an 
    internal buffer by SQLite within the call to sqlite3_config. Hence the 
    application may discard the parameter after the call to sqlite3_config() 
    returns.

    The xInit() method is called once for each effective call to 
    sqlite3_initialize() (usually only once during the lifetime of the process). 
    The xInit() method is passed a copy of the sqlite3_pcache_methods2.pArg 
    value. The intent of the xInit() method is to set up global data structures 
    required by the custom page cache implementation. If the xInit() method is 
    NULL, then the built-in default page cache is used instead of the 
    application defined page cache.

    The xShutdown() method is called by sqlite3_shutdown(). It can be used to 
    clean up any outstanding resources before process shutdown, if required. The 
    xShutdown() method may be NULL.

    SQLite automatically serializes calls to the xInit method, so the xInit 
    method need not be threadsafe. The xShutdown method is only called from 
    sqlite3_shutdown() so it does not need to be threadsafe either. All other 
    methods must be threadsafe in multithreaded applications.

    SQLite will never invoke xInit() more than once without an intervening call 
    to xShutdown().

    SQLite invokes the xCreate() method to construct a new cache instance. 
    SQLite will typically create one cache instance for each open database file, 
    though this is not guaranteed. The first parameter, szPage, is the size in 
    bytes of the pages that must be allocated by the cache. szPage will always a 
    power of two. The second parameter szExtra is a number of bytes of extra 
    storage associated with each page cache entry. The szExtra parameter will a 
    number less than 250. SQLite will use the extra szExtra bytes on each page 
    to store metadata about the underlying database page on disk. The value 
    passed into szExtra depends on the SQLite version, the target platform, and 
    how SQLite was compiled. The third argument to xCreate(), bPurgeable, is 
    true if the cache being created will be used to cache database pages of a 
    file stored on disk, or false if it is used for an in-memory database. The 
    cache implementation does not have to do anything special based with the 
    value of bPurgeable; it is purely advisory. On a cache where bPurgeable is 
    false, SQLite will never invoke xUnpin() except to deliberately delete a 
    page. In other words, calls to xUnpin() on a cache with bPurgeable set to 
    false will always have the "discard" flag set to true. Hence, a cache 
    created with bPurgeable false will never contain any unpinned pages.

    The xCachesize() method may be called at any time by SQLite to set the 
    suggested maximum cache-size (number of pages stored by) the cache instance 
    passed as the first argument. This is the value configured using the SQLite 
    "PRAGMA cache_size" command. As with the bPurgeable parameter, the 
    implementation is not required to do anything with this value; it is 
    advisory only.

    The xPagecount() method must return the number of pages currently stored in 
    the cache, both pinned and unpinned.

    The xFetch() method locates a page in the cache and returns a pointer to an 
    sqlite3_pcache_page object associated with that page, or a NULL pointer. The 
    pBuf element of the returned sqlite3_pcache_page object will be a pointer to 
    a buffer of szPage bytes used to store the content of a single database 
    page. The pExtra element of sqlite3_pcache_page will be a pointer to the 
    szExtra bytes of extra storage that SQLite has requested for each entry in 
    the page cache.

    The page to be fetched is determined by the key. The minimum key value is 1. 
    After it has been retrieved using xFetch, the page is considered to be 
    "pinned". 

    If the requested page is already in the page cache, then the page cache 
    implementation must return a pointer to the page buffer with its content 
    intact. If the requested page is not already in the cache, then the cache 
    implementation should use the value of the createFlag parameter to help it 
    determined what action to take.

    SQLite will normally invoke xFetch() with a createFlag of 0 or 1. SQLite 
    will only use a createFlag of 2 after a prior call with a createFlag of 1 
    failed. In between the xFetch() calls, SQLite may attempt to unpin one or 
    more cache pages by spilling the content of pinned pages to disk and 
    synching the operating system disk cache.

    xUnpin() is called by SQLite with a pointer to a currently pinned page as 
    its second argument. If the third parameter, discard, is non-zero, then the 
    page must be evicted from the cache. If the discard parameter is zero, then 
    the page may be discarded or retained at the discretion of page cache 
    implementation. The page cache implementation may choose to evict unpinned 
    pages at any time.

    The cache must not perform any reference counting. A single call to xUnpin() 
    unpins the page regardless of the number of prior calls to xFetch().

    The xRekey() method is used to change the key value associated with the page 
    passed as the second argument. If the cache previously contains an entry 
    associated with newKey, it must be discarded. Any prior cache entry 
    associated with newKey is guaranteed not to be pinned.

    When SQLite calls the xTruncate() method, the cache must discard all 
    existing cache entries with page numbers (keys) greater than or equal to the 
    value of the iLimit parameter passed to xTruncate(). If any of these pages 
    are pinned, they are implicitly unpinned, meaning that they can be safely 
    discarded.

    The xDestroy() method is used to delete a cache allocated by xCreate(). All 
    resources associated with the specified cache should be freed. After calling 
    the xDestroy() method, SQLite considers the sqlite3_pcache* handle invalid, 
    and will not use it with any other sqlite3_pcache_methods2 functions.

    SQLite invokes the xShrink() method when it wants the page cache to free up 
    as much of heap memory as possible. The page cache implementation is not 
    obligated to free any memory, but well-behaved implementations should do 
    their best. }
  sqlite3_pcache_methods2 = record
    iVersion : Integer;
    pArg : Pointer;
    xInit : function (ptr : Pointer) : Integer; cdecl;
    xShutdown : procedure (ptr : Pointer); cdecl;
    xCreate : function (szPage : Integer; szExtra : Integer; bPurgeable :
      Integer) : psqlite3_pcache; cdecl;
    xCachesize : procedure (pCache : psqlite3_pcache; nCachesize : Integer);
      cdecl;
    xPagecount : function (pCache : psqlite3_pcache) : Integer; cdecl;
    xFetch : function (pCache : psqlite3_pcache; key : Cardinal; createFlag :
      Integer) : psqlite3_pcache_page; cdecl;
    xUnpin : procedure (pCache : psqlite3_pcache; pPage : psqlite3_pcache_page;
      discard : Integer); cdecl;
    xRekey : procedure (pCahce : psqlite3_pcache; pPage : psqlite3_pcache_page;
      oldKey : Cardinal; newKey : Cardinal); cdecl;
    xTruncate : procedure (pCache : psqlite3_pcache; iLimit : Cardinal); cdecl;
    xDestroy : procedure (pCache : psqlite3_pcache); cdecl;
    xShrink : procedure (pCache : psqlite3_pcache); cdecl;
  end;

  { This is the obsolete pcache_methods object that has now been replaced by 
    sqlite3_pcache_methods2. This object is not used by SQLite. It is retained 
    in the header file for backwards compatibility only. }
  sqlite3_pcache_methods = record
    pArg : Pointer;
    xInit : function (ptr : Pointer) : Integer; cdecl;
    xShutdown : procedure (ptr : Pointer); cdecl;
    xCreate : function (szPage : Integer; bPurgeable : Integer) : 
      psqlite3_pcache; cdecl;
    xCachesize : procedure (pCache : psqlite3_pcache; nCachesize : Integer);
      cdecl;
    xPagecount : function (pCache : psqlite3_pcache) : Integer; cdecl;
    xFetch : function (pCache : psqlite3_pcache; key : Cardinal; createFlag :
      Cardinal) : Pointer; cdecl;
    xUnpin : procedure (pCache : psqlite3_pcache; ptr : Pointer; discard : 
      Integer); cdecl;
    xRekey : procedure (pCache : psqlite3_pcache; ptr : Pointer; oldKey :
      Cardinal; newKey : Cardinal); cdecl;
    xTruncate : procedure (pCache : psqlite3_pcache; iLimit : Cardinal); cdecl;
    xDestroy : procedure (pCache : psqlite3_pcache); cdecl;
  end;

  { The sqlite3_backup object records state information about an ongoing online 
    backup operation. The sqlite3_backup object is created by a call to 
    sqlite3_backup_init() and is destroyed by a call to 
    sqlite3_backup_finish(). }
  sqlite3_backup = record

  end;

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

{ The sqlite3_initialize() routine initializes the SQLite library. The 
  sqlite3_shutdown() routine deallocates any resources that were allocated by 
  sqlite3_initialize(). These routines are designed to aid in process 
  initialization and shutdown on embedded systems. Workstation applications 
  using SQLite normally do not need to invoke either of these routines.

  A call to sqlite3_initialize() is an "effective" call if it is the first time 
  sqlite3_initialize() is invoked during the lifetime of the process, or if it 
  is the first time sqlite3_initialize() is invoked following a call to 
  sqlite3_shutdown(). Only an effective call of sqlite3_initialize() does any 
  initialization. All other calls are harmless no-ops.

  A call to sqlite3_shutdown() is an "effective" call if it is the first call to 
  sqlite3_shutdown() since the last sqlite3_initialize(). Only an effective call 
  to sqlite3_shutdown() does any deinitialization. All other valid calls to 
  sqlite3_shutdown() are harmless no-ops.

  The sqlite3_initialize() interface is threadsafe, but sqlite3_shutdown() is 
  not. The sqlite3_shutdown() interface must only be called from a single 
  thread. All open database connections must be closed and all other SQLite 
  resources must be deallocated prior to invoking sqlite3_shutdown().

  Among other things, sqlite3_initialize() will invoke sqlite3_os_init(). 
  Similarly, sqlite3_shutdown() will invoke sqlite3_os_end().

  The sqlite3_initialize() routine returns SQLITE_OK on success. If for some 
  reason, sqlite3_initialize() is unable to initialize the library (perhaps it 
  is unable to allocate a needed resource such as a mutex) it returns an error 
  code other than SQLITE_OK.

  The sqlite3_initialize() routine is called internally by many other SQLite 
  interfaces so that an application usually does not need to invoke 
  sqlite3_initialize() directly. For example, sqlite3_open() calls 
  sqlite3_initialize() so the SQLite library will be automatically initialized 
  when sqlite3_open() is called if it has not be initialized already. However, 
  if SQLite is compiled with the SQLITE_OMIT_AUTOINIT compile-time option, then 
  the automatic calls to sqlite3_initialize() are omitted and the application 
  must call sqlite3_initialize() directly prior to using any other SQLite 
  interface. For maximum portability, it is recommended that applications always 
  invoke sqlite3_initialize() directly prior to using any other SQLite 
  interface. Future releases of SQLite may require this. In other words, the 
  behavior exhibited when SQLite is compiled with SQLITE_OMIT_AUTOINIT might 
  become the default behavior in some future release of SQLite.

  The sqlite3_os_init() routine does operating-system specific initialization of 
  the SQLite library. The sqlite3_os_end() routine undoes the effect of 
  sqlite3_os_init(). Typical tasks performed by these routines include 
  allocation or deallocation of static resources, initialization of global 
  variables, setting up a default sqlite3_vfs module, or setting up a default 
  configuration using sqlite3_config().

  The application should never invoke either sqlite3_os_init() or 
  sqlite3_os_end() directly. The application should only invoke 
  sqlite3_initialize() and sqlite3_shutdown(). The sqlite3_os_init() interface 
  is called automatically by sqlite3_initialize() and sqlite3_os_end() is called 
  by sqlite3_shutdown(). Appropriate implementations for sqlite3_os_init() and 
  sqlite3_os_end() are built into SQLite when it is compiled for Unix, Windows, 
  or OS/2. When built for other platforms (using the SQLITE_OS_OTHER=1 
  compile-time option) the application must supply a suitable implementation for 
  sqlite3_os_init() and sqlite3_os_end(). An application-supplied implementation 
  of sqlite3_os_init() or sqlite3_os_end() must return SQLITE_OK on success and 
  some other error code upon failure. }
function sqlite3_initialize : Integer; cdecl; external sqlite3_lib;
function sqlite3_shutdown : Integer; cdecl; external sqlite3_lib;
function sqlite3_os_init : Integer; cdecl; external sqlite3_lib;
function sqlite3_os_end : Integer; cdecl; external sqlite3_lib;

{ The sqlite3_config() interface is used to make global configuration changes to 
  SQLite in order to tune SQLite to the specific needs of the application. The 
  default configuration is recommended for most applications and so this routine 
  is usually not necessary. It is provided to support rare applications with 
  unusual needs.

  The sqlite3_config() interface is not threadsafe. The application must ensure 
  that no other SQLite interfaces are invoked by other threads while 
  sqlite3_config() is running.

  The sqlite3_config() interface may only be invoked prior to library 
  initialization using sqlite3_initialize() or after shutdown by 
  sqlite3_shutdown(). If sqlite3_config() is called after sqlite3_initialize() 
  and before sqlite3_shutdown() then it will return SQLITE_MISUSE. Note, 
  however, that sqlite3_config() can be called as part of the implementation of 
  an application-defined sqlite3_os_init().

  The first argument to sqlite3_config() is an integer configuration option that 
  determines what property of SQLite is to be configured. Subsequent arguments 
  vary depending on the configuration option in the first argument.

  When a configuration option is set, sqlite3_config() returns SQLITE_OK. If the 
  option is unknown or SQLite is unable to set the option then this routine 
  returns a non-zero error code. }
function sqlite3_config(op : Integer) : Integer; cdecl; varargs; 
  external sqlite3_lib;

{ The sqlite3_db_config() interface is used to make configuration changes to a 
  database connection. The interface is similar to sqlite3_config() except that 
  the changes apply to a single database connection (specified in the first 
  argument).

  The second argument to sqlite3_db_config(D,V,...) is the configuration verb - 
  an integer code that indicates what aspect of the database connection is being 
  configured. Subsequent arguments vary depending on the configuration verb.

  Calls to sqlite3_db_config() return SQLITE_OK if and only if the call is 
  considered successful. }
function sqlite3_db_config(db : psqlite3; op : Integer); cdecl; varargs;
  external sqlite3_lib;

{ The sqlite3_extended_result_codes() routine enables or disables the extended 
  result codes feature of SQLite. The extended result codes are disabled by 
  default for historical compatibility. }
function sqlite3_extended_result_codes(db : psqlite3; onoff : Integer) :
  Integer; cdecl; external sqlite3_lib;

{ Each entry in most SQLite tables (except for WITHOUT ROWID tables) has a 
  unique 64-bit signed integer key called the "rowid". The rowid is always 
  available as an undeclared column named ROWID, OID, or _ROWID_ as long as 
  those names are not also used by explicitly declared columns. If the table has 
  a column of type INTEGER PRIMARY KEY then that column is another alias for the 
  rowid.

  The sqlite3_last_insert_rowid(D) interface usually returns the rowid of the 
  most recent successful INSERT into a rowid table or virtual table on database 
  connection D. Inserts into WITHOUT ROWID tables are not recorded. If no 
  successful INSERTs into rowid tables have ever occurred on the database 
  connection D, then sqlite3_last_insert_rowid(D) returns zero.

  As well as being set automatically as rows are inserted into database tables, 
  the value returned by this function may be set explicitly by 
  sqlite3_set_last_insert_rowid()

  Some virtual table implementations may INSERT rows into rowid tables as part 
  of committing a transaction (e.g. to flush data accumulated in memory to 
  disk). In this case subsequent calls to this function return the rowid 
  associated with these internal INSERT operations, which leads to unintuitive 
  results. Virtual table implementations that do write to rowid tables in this 
  way can avoid this problem by restoring the original rowid value using 
  sqlite3_set_last_insert_rowid() before returning control to the user.

  If an INSERT occurs within a trigger then this routine will return the rowid 
  of the inserted row as long as the trigger is running. Once the trigger 
  program ends, the value returned by this routine reverts to what it was before 
  the trigger was fired.

  An INSERT that fails due to a constraint violation is not a successful INSERT 
  and does not change the value returned by this routine. Thus INSERT OR FAIL, 
  INSERT OR IGNORE, INSERT OR ROLLBACK, and INSERT OR ABORT make no changes to 
  the return value of this routine when their insertion fails. When INSERT OR 
  REPLACE encounters a constraint violation, it does not fail. The INSERT 
  continues to completion after deleting rows that caused the constraint problem 
  so INSERT OR REPLACE will always change the return value of this interface.

  For the purposes of this routine, an INSERT is considered to be successful 
  even if it is subsequently rolled back.

  This function is accessible to SQL statements via the last_insert_rowid() SQL 
  function.

  If a separate thread performs a new INSERT on the same database connection 
  while the sqlite3_last_insert_rowid() function is running and thus changes the 
  last insert rowid, then the value returned by sqlite3_last_insert_rowid() is 
  unpredictable and might not equal either the old or the new last insert 
  rowid. }
function sqlite3_last_insert_rowid(db : psqlite3) : sqlite3_int64; cdecl;
  external sqlite3_lib;

{ The sqlite3_set_last_insert_rowid(D, R) method allows the application to set 
  the value returned by calling sqlite3_last_insert_rowid(D) to R without 
  inserting a row into the database. }
procedure sqlite3_set_last_insert_rowid(db : psqlite3; iRowid : sqlite3_int64);
  cdecl; external sqlite3_lib;

{ This function returns the number of rows modified, inserted or deleted by the 
  most recently completed INSERT, UPDATE or DELETE statement on the database 
  connection specified by the only parameter. Executing any other type of SQL 
  statement does not modify the value returned by this function.

  Only changes made directly by the INSERT, UPDATE or DELETE statement are 
  considered - auxiliary changes caused by triggers, foreign key actions or 
  REPLACE constraint resolution are not counted.

  Changes to a view that are intercepted by INSTEAD OF triggers are not counted. 
  The value returned by sqlite3_changes() immediately after an INSERT, UPDATE or 
  DELETE statement run on a view is always zero. Only changes made to real 
  tables are counted.

  Things are more complicated if the sqlite3_changes() function is executed 
  while a trigger program is running. This may happen if the program uses the 
  changes() SQL function, or if some other callback function invokes 
  sqlite3_changes() directly. Essentially:

    Before entering a trigger program the value returned by sqlite3_changes() 
    function is saved. After the trigger program has finished, the original 
    value is restored.

    Within a trigger program each INSERT, UPDATE and DELETE statement sets the 
    value returned by sqlite3_changes() upon completion as normal. Of course, 
    this value will not include any changes performed by sub-triggers, as the 
    sqlite3_changes() value will be saved and restored after each sub-trigger 
    has run. 

  This means that if the changes() SQL function (or similar) is used by the 
  first INSERT, UPDATE or DELETE statement within a trigger, it returns the 
  value as set when the calling statement began executing. If it is used by the 
  second or subsequent such statement within a trigger program, the value 
  returned reflects the number of rows modified by the previous INSERT, UPDATE 
  or DELETE statement within the same trigger.

  If a separate thread makes changes on the same database connection while 
  sqlite3_changes() is running then the value returned is unpredictable and not 
  meaningful. }
function sqlite3_changes(db : psqlite3) : Integer; cdecl; external sqlite3_lib;

{ This function returns the total number of rows inserted, modified or deleted 
  by all INSERT, UPDATE or DELETE statements completed since the database 
  connection was opened, including those executed as part of trigger programs. 
  Executing any other type of SQL statement does not affect the value returned 
  by sqlite3_total_changes().

  Changes made as part of foreign key actions are included in the count, but 
  those made as part of REPLACE constraint resolution are not. Changes to a view 
  that are intercepted by INSTEAD OF triggers are not counted.

  The sqlite3_total_changes(D) interface only reports the number of rows that 
  changed due to SQL statement run against database connection D. Any changes by 
  other database connections are ignored. To detect changes against a database 
  file from other database connections use the PRAGMA data_version command or 
  the SQLITE_FCNTL_DATA_VERSION file control.

  If a separate thread makes changes on the same database connection while 
  sqlite3_total_changes() is running then the value returned is unpredictable 
  and not meaningful. }
function sqlite3_total_changes(db : psqlite3) : Integer; cdecl; 
  external sqlite3_lib;

{ This function causes any pending database operation to abort and return at its 
  earliest opportunity. This routine is typically called in response to a user 
  action such as pressing "Cancel" or Ctrl-C where the user wants a long query 
  operation to halt immediately.

  It is safe to call this routine from a thread different from the thread that 
  is currently running the database operation. But it is not safe to call this 
  routine with a database connection that is closed or might close before 
  sqlite3_interrupt() returns.

  If an SQL operation is very nearly finished at the time when 
  sqlite3_interrupt() is called, then it might not have an opportunity to be 
  interrupted and might continue to completion.

  An SQL operation that is interrupted will return SQLITE_INTERRUPT. If the 
  interrupted SQL operation is an INSERT, UPDATE, or DELETE that is inside an 
  explicit transaction, then the entire transaction will be rolled back 
  automatically.

  The sqlite3_interrupt(D) call is in effect until all currently running SQL 
  statements on database connection D complete. Any new SQL statements that are 
  started after the sqlite3_interrupt() call and before the running statement 
  count reaches zero are interrupted as if they had been running prior to the 
  sqlite3_interrupt() call. New SQL statements that are started after the 
  running statement count reaches zero are not effected by the 
  sqlite3_interrupt(). A call to sqlite3_interrupt(D) that occurs when there are 
  no running SQL statements is a no-op and has no effect on SQL statements that 
  are started after the sqlite3_interrupt() call returns. }
procedure sqlite3_interrupt(db : psqlite3); cdecl; external sqlite3_lib;

{ These routines are useful during command-line input to determine if the 
  currently entered text seems to form a complete SQL statement or if additional 
  input is needed before sending the text into SQLite for parsing. These 
  routines return 1 if the input string appears to be a complete SQL statement. 
  A statement is judged to be complete if it ends with a semicolon token and is 
  not a prefix of a well-formed CREATE TRIGGER statement. Semicolons that are 
  embedded within string literals or quoted identifier names or comments are not 
  independent tokens (they are part of the token in which they are embedded) and 
  thus do not count as a statement terminator. Whitespace and comments that 
  follow the final semicolon are ignored.

  These routines return 0 if the statement is incomplete. If a memory allocation 
  fails, then SQLITE_NOMEM is returned.

  These routines do not parse the SQL statements thus will not detect 
  syntactically incorrect SQL.

  If SQLite has not been initialized using sqlite3_initialize() prior to 
  invoking sqlite3_complete16() then sqlite3_initialize() is invoked 
  automatically by sqlite3_complete16(). If that initialization fails, then the 
  return value from sqlite3_complete16() will be non-zero regardless of whether 
  or not the input SQL is complete.

  The input to sqlite3_complete() must be a zero-terminated UTF-8 string.

  The input to sqlite3_complete16() must be a zero-terminated UTF-16 string in 
  native byte order. }
function sqlite3_complete(const zSql : PChar) : Integer; cdecl; 
  external sqlite3_lib;
function sqlite3_complete16(const zSql : PChar) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_busy_handler(D,X,P) routine sets a callback function X that might 
  be invoked with argument P whenever an attempt is made to access a database 
  table associated with database connection D when another thread or process has 
  the table locked. The sqlite3_busy_handler() interface is used to implement 
  sqlite3_busy_timeout() and PRAGMA busy_timeout.

  If the busy callback is NULL, then SQLITE_BUSY is returned immediately upon 
  encountering the lock. If the busy callback is not NULL, then the callback 
  might be invoked with two arguments.

  The first argument to the busy handler is a copy of the void* pointer which is 
  the third argument to sqlite3_busy_handler(). The second argument to the busy 
  handler callback is the number of times that the busy handler has been invoked 
  previously for the same locking event. If the busy callback returns 0, then no 
  additional attempts are made to access the database and SQLITE_BUSY is 
  returned to the application. If the callback returns non-zero, then another 
  attempt is made to access the database and the cycle repeats.

  The presence of a busy handler does not guarantee that it will be invoked when 
  there is lock contention. If SQLite determines that invoking the busy handler 
  could result in a deadlock, it will go ahead and return SQLITE_BUSY to the 
  application instead of invoking the busy handler. Consider a scenario where 
  one process is holding a read lock that it is trying to promote to a reserved 
  lock and a second process is holding a reserved lock that it is trying to 
  promote to an exclusive lock. The first process cannot proceed because it is 
  blocked by the second and the second process cannot proceed because it is 
  blocked by the first. If both processes invoke the busy handlers, neither will 
  make any progress. Therefore, SQLite returns SQLITE_BUSY for the first 
  process, hoping that this will induce the first process to release its read 
  lock and allow the second process to proceed.

  The default busy callback is NULL.

  There can only be a single busy handler defined for each database connection. 
  Setting a new busy handler clears any previously set handler. Note that 
  calling sqlite3_busy_timeout() or evaluating PRAGMA busy_timeout=N will change 
  the busy handler and thus clear any previously set busy handler.

  The busy callback should not take any actions which modify the database 
  connection that invoked the busy handler. In other words, the busy handler is 
  not reentrant. Any such actions result in undefined behavior.

  A busy handler must not close the database connection or prepared statement 
  that invoked the busy handler. }
function sqlite3_busy_handler(db : psqlite3; callback : xBusy_callback; pArg :
  Pointer) : Integer; cdecl; external sqlite3_lib;

{ This routine sets a busy handler that sleeps for a specified amount of time 
  when a table is locked. The handler will sleep multiple times until at least 
  "ms" milliseconds of sleeping have accumulated. After at least "ms" 
  milliseconds of sleeping, the handler returns 0 which causes sqlite3_step() to 
  return SQLITE_BUSY.

  Calling this routine with an argument less than or equal to zero turns off all 
  busy handlers.

  There can only be a single busy handler for a particular database connection 
  at any given moment. If another busy handler was defined (using 
  sqlite3_busy_handler()) prior to calling this routine, that other busy handler 
  is cleared. }
function sqlite3_busy_timeout(db : psqlite3; ms : Integer) : Integer; cdecl;
  external sqlite3_lib;

{ This is a legacy interface that is preserved for backwards compatibility. Use 
  of this interface is not recommended.

  Definition: A result table is memory data structure created by the 
  sqlite3_get_table() interface. A result table records the complete query 
  results from one or more queries.

  The table conceptually has a number of rows and columns. But these numbers are 
  not part of the result table itself. These numbers are obtained separately. 
  Let N be the number of rows and M be the number of columns.

  A result table is an array of pointers to zero-terminated UTF-8 strings. There 
  are (N+1)*M elements in the array. The first M pointers point to 
  zero-terminated strings that contain the names of the columns. The remaining 
  entries all point to query results. NULL values result in NULL pointers. All 
  other values are in their UTF-8 zero-terminated string representation as 
  returned by sqlite3_column_text().

  A result table might consist of one or more memory allocations. It is not safe 
  to pass a result table directly to sqlite3_free(). A result table should be 
  deallocated using sqlite3_free_table().
  
  The sqlite3_get_table() function evaluates one or more semicolon-separated SQL 
  statements in the zero-terminated UTF-8 string of its 2nd parameter and 
  returns a result table to the pointer given in its 3rd parameter.

  After the application has finished with the result from sqlite3_get_table(), 
  it must pass the result table pointer to sqlite3_free_table() in order to 
  release the memory that was malloced. Because of the way the sqlite3_malloc() 
  happens within sqlite3_get_table(), the calling function must not try to call 
  sqlite3_free() directly. Only sqlite3_free_table() is able to release the 
  memory properly and safely.

  The sqlite3_get_table() interface is implemented as a wrapper around 
  sqlite3_exec(). The sqlite3_get_table() routine does not have access to any 
  internal data structures of SQLite. It uses only the public interface defined 
  here. As a consequence, errors that occur in the wrapper layer outside of the 
  internal sqlite3_exec() call are not reflected in subsequent calls to 
  sqlite3_errcode() or sqlite3_errmsg(). }
function sqlite3_get_table(db : psqlite3; const zSql : PChar; pazResult :
  PPPChar; pnRow : PInteger; pnColumn : PInteger; pzErrmsg : PPChar) : Integer;
  cdecl; external sqlite3_lib;
procedure sqlite3_free_table(result : PPChar); cdecl; external sqlite3_lib;

{ These routines are work-alikes of the "printf()" family of functions from the 
  standard C library. These routines understand most of the common formatting 
  options from the standard library printf() plus some additional non-standard 
  formats (%q, %Q, %w, and %z). See the built-in printf() documentation for 
  details.

  The sqlite3_mprintf() and sqlite3_vmprintf() routines write their results into 
  memory obtained from sqlite3_malloc64(). The strings returned by these two 
  routines should be released by sqlite3_free(). Both routines return a NULL 
  pointer if sqlite3_malloc64() is unable to allocate enough memory to hold the 
  resulting string.

  The sqlite3_snprintf() routine is similar to "snprintf()" from the standard C 
  library. The result is written into the buffer supplied as the second 
  parameter whose size is given by the first parameter. Note that the order of 
  the first two parameters is reversed from snprintf(). This is an historical 
  accident that cannot be fixed without breaking backwards compatibility. Note 
  also that sqlite3_snprintf() returns a pointer to its buffer instead of the 
  number of characters actually written into the buffer. We admit that the
  number of characters written would be a more useful return value but we cannot 
  change the implementation of sqlite3_snprintf() now without breaking 
  compatibility.

  As long as the buffer size is greater than zero, sqlite3_snprintf() guarantees 
  that the buffer is always zero-terminated. The first parameter "n" is the 
  total size of the buffer, including space for the zero terminator. So the 
  longest string that can be completely written will be n-1 characters.

  The sqlite3_vsnprintf() routine is a varargs version of sqlite3_snprintf(). }
function sqlite3_mprintf(const zName : PChar) : PChar; cdecl; varargs;
  external sqlite3_lib;
function sqlite3_vmprintf(const zName : PChar; va_list : array of const) : 
  PChar; cdecl; varargs; external sqlite3_lib;
function sqlite3_snprintf(size : Integer; zName : PChar) : PChar; cdecl;
  varargs; external sqlite3_lib;
function sqlite3_vsnprintf(size : Integer; zName : PChar; const zFormat : PChar;
  va_list : array of const) : PChar; cdecl; varargs; external sqlite3_lib;

{ The SQLite core uses these three routines for all of its own internal memory 
  allocation needs. "Core" in the previous sentence does not include 
  operating-system specific VFS implementation. The Windows VFS uses native 
  malloc() and free() for some operations.

  The sqlite3_malloc() routine returns a pointer to a block of memory at least N 
  bytes in length, where N is the parameter. If sqlite3_malloc() is unable to 
  obtain sufficient free memory, it returns a NULL pointer. If the parameter N 
  to sqlite3_malloc() is zero or negative then sqlite3_malloc() returns a NULL 
  pointer.

  The sqlite3_malloc64(N) routine works just like sqlite3_malloc(N) except that 
  N is an unsigned 64-bit integer instead of a signed 32-bit integer.

  Calling sqlite3_free() with a pointer previously returned by sqlite3_malloc() 
  or sqlite3_realloc() releases that memory so that it might be reused. The 
  sqlite3_free() routine is a no-op if is called with a NULL pointer. Passing a 
  NULL pointer to sqlite3_free() is harmless. After being freed, memory should 
  neither be read nor written. Even reading previously freed memory might result 
  in a segmentation fault or other severe error. Memory corruption, a 
  segmentation fault, or other severe error might result if sqlite3_free() is 
  called with a non-NULL pointer that was not obtained from sqlite3_malloc() or 
  sqlite3_realloc().

  The sqlite3_realloc(X,N) interface attempts to resize a prior memory 
  allocation X to be at least N bytes. If the X parameter to 
  sqlite3_realloc(X,N) is a NULL pointer then its behavior is identical to 
  calling sqlite3_malloc(N). If the N parameter to sqlite3_realloc(X,N) is zero 
  or negative then the behavior is exactly the same as calling sqlite3_free(X). 
  sqlite3_realloc(X,N) returns a pointer to a memory allocation of at least N 
  bytes in size or NULL if insufficient memory is available. If M is the size of 
  the prior allocation, then min(N,M) bytes of the prior allocation are copied 
  into the beginning of buffer returned by sqlite3_realloc(X,N) and the prior 
  allocation is freed. If sqlite3_realloc(X,N) returns NULL and N is positive, 
  then the prior allocation is not freed.

  The sqlite3_realloc64(X,N) interfaces works the same as sqlite3_realloc(X,N) 
  except that N is a 64-bit unsigned integer instead of a 32-bit signed integer.

  If X is a memory allocation previously obtained from sqlite3_malloc(), 
  sqlite3_malloc64(), sqlite3_realloc(), or sqlite3_realloc64(), then 
  sqlite3_msize(X) returns the size of that memory allocation in bytes. The 
  value returned by sqlite3_msize(X) might be larger than the number of bytes 
  requested when X was allocated. If X is a NULL pointer then sqlite3_msize(X) 
  returns zero. If X points to something that is not the beginning of memory 
  allocation, or if it points to a formerly valid memory allocation that has now 
  been freed, then the behavior of sqlite3_msize(X) is undefined and possibly 
  harmful.

  The memory returned by sqlite3_malloc(), sqlite3_realloc(), 
  sqlite3_malloc64(), and sqlite3_realloc64() is always aligned to at least an 8 
  byte boundary, or to a 4 byte boundary if the SQLITE_4_BYTE_ALIGNED_MALLOC 
  compile-time option is used.

  The pointer arguments to sqlite3_free() and sqlite3_realloc() must be either 
  NULL or else pointers obtained from a prior invocation of sqlite3_malloc() or 
  sqlite3_realloc() that have not yet been released.

  The application must not read or write any part of a block of memory after it 
  has been released using sqlite3_free() or sqlite3_realloc(). }
function sqlite3_malloc(size : Integer) : Pointer; cdecl; external sqlite3_lib;
function sqlite3_malloc64(size : sqlite3_uint64) : Pointer; cdecl;
  external sqlite3_lib;
function sqlite3_realloc(ptr : Pointer; size : Integer) : Pointer; cdecl;
  external sqlite3_lib;
function sqlite3_realloc64(ptr : Pointer; size : sqlite3_uint64) : Pointer;
  cdecl; external sqlite3_lib;
procedure sqlite3_free(ptr : Pointer); cdecl; external sqlite3_lib;
function sqlite3_msize(ptr : Pointer) : sqlite3_uint64; cdecl; 
  external sqlite3_lib;

{ SQLite provides these two interfaces for reporting on the status of the 
  sqlite3_malloc(), sqlite3_free(), and sqlite3_realloc() routines, which form 
  the built-in memory allocation subsystem.

  The sqlite3_memory_used() routine returns the number of bytes of memory 
  currently outstanding (malloced but not freed). The sqlite3_memory_highwater() 
  routine returns the maximum value of sqlite3_memory_used() since the 
  high-water mark was last reset. The values returned by sqlite3_memory_used() 
  and sqlite3_memory_highwater() include any overhead added by SQLite in its 
  implementation of sqlite3_malloc(), but not overhead added by the any 
  underlying system library routines that sqlite3_malloc() may call.

  The memory high-water mark is reset to the current value of 
  sqlite3_memory_used() if and only if the parameter to 
  sqlite3_memory_highwater() is true. The value returned by 
  sqlite3_memory_highwater(1) is the high-water mark prior to the reset. }
function sqlite3_memory_used : sqlite3_int64; cdecl; external sqlite3_lib;
function sqlite3_memory_highwater : sqlite3_int64; cdecl; external sqlite3_lib;

{ SQLite contains a high-quality pseudo-random number generator (PRNG) used to 
  select random ROWIDs when inserting new records into a table that already uses 
  the largest possible ROWID. The PRNG is also used for the built-in random() 
  and randomblob() SQL functions. This interface allows applications to access 
  the same PRNG for other purposes.

  A call to this routine stores N bytes of randomness into buffer P. The P 
  parameter can be a NULL pointer.

  If this routine has not been previously called or if the previous call had N 
  less than one or a NULL pointer for P, then the PRNG is seeded using 
  randomness obtained from the xRandomness method of the default sqlite3_vfs 
  object. If the previous call to this routine had an N of 1 or more and a 
  non-NULL P then the pseudo-randomness is generated internally and without 
  recourse to the sqlite3_vfs xRandomness method. }
procedure sqlite3_randomness(N : Integer; P : Pointer); cdecl; 
  external sqlite3_lib;

{ This routine registers an authorizer callback with a particular database 
  connection, supplied in the first argument. The authorizer callback is invoked 
  as SQL statements are being compiled by sqlite3_prepare() or its variants 
  sqlite3_prepare_v2(), sqlite3_prepare_v3(), sqlite3_prepare16(), 
  sqlite3_prepare16_v2(), and sqlite3_prepare16_v3(). At various points during 
  the compilation process, as logic is being created to perform various actions, 
  the authorizer callback is invoked to see if those actions are allowed. The 
  authorizer callback should return SQLITE_OK to allow the action, SQLITE_IGNORE 
  to disallow the specific action but allow the SQL statement to continue to be 
  compiled, or SQLITE_DENY to cause the entire SQL statement to be rejected with 
  an error. If the authorizer callback returns any value other than 
  SQLITE_IGNORE, SQLITE_OK, or SQLITE_DENY then the sqlite3_prepare_v2() or 
  equivalent call that triggered the authorizer will fail with an error message.

  When the callback returns SQLITE_OK, that means the operation requested is ok. 
  When the callback returns SQLITE_DENY, the sqlite3_prepare_v2() or equivalent 
  call that triggered the authorizer will fail with an error message explaining 
  that access is denied.

  The first parameter to the authorizer callback is a copy of the third 
  parameter to the sqlite3_set_authorizer() interface. The second parameter to 
  the callback is an integer action code that specifies the particular action to 
  be authorized. The third through sixth parameters to the callback are either 
  NULL pointers or zero-terminated strings that contain additional details about 
  the action to be authorized. Applications must always be prepared to encounter 
  a NULL pointer in any of the third through the sixth parameters of the 
  authorization callback.

  If the action code is SQLITE_READ and the callback returns SQLITE_IGNORE then 
  the prepared statement statement is constructed to substitute a NULL value in 
  place of the table column that would have been read if SQLITE_OK had been 
  returned. The SQLITE_IGNORE return can be used to deny an untrusted user 
  access to individual columns of a table. When a table is referenced by a 
  SELECT but no column values are extracted from that table (for example in a 
  query like "SELECT count(*) FROM tab") then the SQLITE_READ authorizer 
  callback is invoked once for that table with a column name that is an empty 
  string. If the action code is SQLITE_DELETE and the callback returns 
  SQLITE_IGNORE then the DELETE operation proceeds but the truncate optimization 
  is disabled and all rows are deleted individually.

  An authorizer is used when preparing SQL statements from an untrusted source, 
  to ensure that the SQL statements do not try to access data they are not 
  allowed to see, or that they do not try to execute malicious statements that 
  damage the database. For example, an application may allow a user to enter 
  arbitrary SQL queries for evaluation by a database. But the application does 
  not want the user to be able to make arbitrary changes to the database. An 
  authorizer could then be put in place while the user-entered SQL is being 
  prepared that disallows everything except SELECT statements.

  Applications that need to process SQL from untrusted sources might also 
  consider lowering resource limits using sqlite3_limit() and limiting database 
  size using the max_page_count PRAGMA in addition to using an authorizer.

  Only a single authorizer can be in place on a database connection at a time. 
  Each call to sqlite3_set_authorizer overrides the previous call. Disable the 
  authorizer by installing a NULL callback. The authorizer is disabled by 
  default.

  The authorizer callback must not do anything that will modify the database 
  connection that invoked the authorizer callback. Note that 
  sqlite3_prepare_v2() and sqlite3_step() both modify their database connections 
  for the meaning of "modify" in this paragraph.

  When sqlite3_prepare_v2() is used to prepare a statement, the statement might 
  be re-prepared during sqlite3_step() due to a schema change. Hence, the 
  application should ensure that the correct authorizer callback remains in 
  place during the sqlite3_step().

  Note that the authorizer callback is invoked only during sqlite3_prepare() or 
  its variants. Authorization is not performed during statement evaluation in 
  sqlite3_step(), unless as stated in the previous paragraph, sqlite3_step() 
  invokes sqlite3_prepare_v2() to reprepare a statement after a schema change. }
function sqlite3_set_authorizer(db : psqlite3; xAuth : xAuth_callback; 
  pUserData : Pointer) : Integer; cdecl; external sqlite3_lib;

{ These routines are deprecated. Use the sqlite3_trace_v2() interface instead of 
  the routines described here.

  These routines register callback functions that can be used for tracing and 
  profiling the execution of SQL statements.

  The callback function registered by sqlite3_trace() is invoked at various 
  times when an SQL statement is being run by sqlite3_step(). The 
  sqlite3_trace() callback is invoked with a UTF-8 rendering of the SQL 
  statement text as the statement first begins executing. Additional 
  sqlite3_trace() callbacks might occur as each triggered subprogram is entered. 
  The callbacks for triggers contain a UTF-8 SQL comment that identifies the 
  trigger.

  The SQLITE_TRACE_SIZE_LIMIT compile-time option can be used to limit the 
  length of bound parameter expansion in the output of sqlite3_trace().

  The callback function registered by sqlite3_profile() is invoked as each SQL 
  statement finishes. The profile callback contains the original statement text 
  and an estimate of wall-clock time of how long that statement took to run. The 
  profile callback time is in units of nanoseconds, however the current 
  implementation is only capable of millisecond resolution so the six least 
  significant digits in the time are meaningless. Future versions of SQLite 
  might provide greater resolution on the profiler callback. Invoking either 
  sqlite3_trace() or sqlite3_trace_v2() will cancel the profile callback. }
function sqlite3_trace(db : psqlite3; xTrace : xTrace_callback) : Pointer;
  cdecl; external sqlite3_lib;
function sqlite3_profile(db : psqlite3; xProfile : xProfile_callback) : Pointer;
  cdecl; external sqlite3_lib;

{ The sqlite3_trace_v2(D,M,X,P) interface registers a trace callback function X 
  against database connection D, using property mask M and context pointer P. If 
  the X callback is NULL or if the M mask is zero, then tracing is disabled. The 
  M argument should be the bitwise OR-ed combination of zero or more 
  SQLITE_TRACE constants.

  Each call to either sqlite3_trace() or sqlite3_trace_v2() overrides (cancels) 
  any prior calls to sqlite3_trace() or sqlite3_trace_v2().

  The X callback is invoked whenever any of the events identified by mask M 
  occur. The integer return value from the callback is currently ignored, though 
  this may change in future releases. Callback implementations should return 
  zero to ensure future compatibility.

  A trace callback is invoked with four arguments: callback(T,C,P,X). The T 
  argument is one of the SQLITE_TRACE constants to indicate why the callback was 
  invoked. The C argument is a copy of the context pointer. The P and X 
  arguments are pointers whose meanings depend on T.

  The sqlite3_trace_v2() interface is intended to replace the legacy interfaces 
  sqlite3_trace() and sqlite3_profile(), both of which are deprecated. }
function sqlite3_trace_v2(db : psqlite3; uMask : Cardinal; xCallback : 
  xCallback_callback; pCtx : Pointer) : Integer; cdecl; external sqlite3_lib;

{ The sqlite3_progress_handler(D,N,X,P) interface causes the callback function X 
  to be invoked periodically during long running calls to sqlite3_exec(), 
  sqlite3_step() and sqlite3_get_table() for database connection D. An example 
  use for this interface is to keep a GUI updated during a large query.

  The parameter P is passed through as the only parameter to the callback 
  function X. The parameter N is the approximate number of virtual machine 
  instructions that are evaluated between successive invocations of the callback 
  X. If N is less than one then the progress handler is disabled.

  Only a single progress handler may be defined at one time per database 
  connection; setting a new progress handler cancels the old one. Setting 
  parameter X to NULL disables the progress handler. The progress handler is 
  also disabled by setting N to a value less than 1.

  If the progress callback returns non-zero, the operation is interrupted. This 
  feature can be used to implement a "Cancel" button on a GUI progress dialog 
  box.

  The progress handler callback must not do anything that will modify the 
  database connection that invoked the progress handler. Note that 
  sqlite3_prepare_v2() and sqlite3_step() both modify their database connections 
  for the meaning of "modify" in this paragraph. }
procedure sqlite3_progress_handler(db : psqlite3; nOps : Integer; xProgress : 
  xProgress_callback; pArg : Pointer); cdecl; external sqlite3_lib;

{ These routines open an SQLite database file as specified by the filename 
  argument. The filename argument is interpreted as UTF-8 for sqlite3_open() and 
  sqlite3_open_v2() and as UTF-16 in the native byte order for sqlite3_open16(). 
  A database connection handle is usually returned in *ppDb, even if an error 
  occurs. The only exception is that if SQLite is unable to allocate memory to 
  hold the sqlite3 object, a NULL will be written into *ppDb instead of a 
  pointer to the sqlite3 object. If the database is opened (and/or created) 
  successfully, then SQLITE_OK is returned. Otherwise an error code is returned. 
  The sqlite3_errmsg() or sqlite3_errmsg16() routines can be used to obtain an 
  English language description of the error following a failure of any of the 
  sqlite3_open() routines.

  The default encoding will be UTF-8 for databases created using sqlite3_open() 
  or sqlite3_open_v2(). The default encoding for databases created using 
  sqlite3_open16() will be UTF-16 in the native byte order.

  Whether or not an error occurs when it is opened, resources associated with 
  the database connection handle should be released by passing it to 
  sqlite3_close() when it is no longer required.

  The sqlite3_open_v2() interface works like sqlite3_open() except that it 
  accepts two additional parameters for additional control over the new database 
  connection. }
function sqlite3_open(const filename : PChar; ppDb : ppsqlite3) : Integer;
  cdecl; external sqlite3_lib;
function sqlite3_open16(const filename : Pointer; ppDb : ppsqlite3) : Integer;
  cdecl; external sqlite3_lib;
function sqlite3_open_v2(const filename : PChar; ppDb : ppsqlite3; flags : 
  Integer; const zVfs : PChar) : Integer; cdecl; external sqlite3_lib;

{ These are utility routines, useful to custom VFS implementations, that check 
  if a database file was a URI that contained a specific query parameter, and if 
  so obtains the value of that query parameter.

  The first parameter to these interfaces (hereafter referred to as F) must be 
  one of:

    A database filename pointer created by the SQLite core and passed into the 
      xOpen() method of a VFS implemention, or
    A filename obtained from sqlite3_db_filename(), or
    A new filename constructed using sqlite3_create_filename(). 

  If the F parameter is not one of the above, then the behavior is undefined and 
  probably undesirable. Older versions of SQLite were more tolerant of invalid F 
  parameters than newer versions.

  If F is a suitable filename (as described in the previous paragraph) and if P 
  is the name of the query parameter, then sqlite3_uri_parameter(F,P) returns 
  the value of the P parameter if it exists or a NULL pointer if P does not 
  appear as a query parameter on F. If P is a query parameter of F and it has no 
  explicit value, then sqlite3_uri_parameter(F,P) returns a pointer to an empty 
  string.

  The sqlite3_uri_boolean(F,P,B) routine assumes that P is a boolean parameter 
  and returns true (1) or false (0) according to the value of P. The 
  sqlite3_uri_boolean(F,P,B) routine returns true (1) if the value of query 
  parameter P is one of "yes", "true", or "on" in any case or if the value 
  begins with a non-zero number. The sqlite3_uri_boolean(F,P,B) routines returns 
  false (0) if the value of query parameter P is one of "no", "false", or "off" 
  in any case or if the value begins with a numeric zero. If P is not a query 
  parameter on F or if the value of P does not match any of the above, then 
  sqlite3_uri_boolean(F,P,B) returns (B!=0).

  The sqlite3_uri_int64(F,P,D) routine converts the value of P into a 64-bit 
  signed integer and returns that integer, or D if P does not exist. If the 
  value of P is something other than an integer, then zero is returned.

  The sqlite3_uri_key(F,N) returns a pointer to the name (not the value) of the 
  N-th query parameter for filename F, or a NULL pointer if N is less than zero 
  or greater than the number of query parameters minus 1. The N value is 
  zero-based so N should be 0 to obtain the name of the first query parameter, 1 
  for the second parameter, and so forth.

  If F is a NULL pointer, then sqlite3_uri_parameter(F,P) returns NULL and 
  sqlite3_uri_boolean(F,P,B) returns B. If F is not a NULL pointer and is not a 
  database file pathname pointer that the SQLite core passed into the xOpen VFS 
  method, then the behavior of this routine is undefined and probably 
  undesirable.

  Beginning with SQLite version 3.31.0 (2020-01-22) the input F parameter can 
  also be the name of a rollback journal file or WAL file in addition to the 
  main database file. Prior to version 3.31.0, these routines would only work if 
  F was the name of the main database file. When the F parameter is the name of 
  the rollback journal or WAL file, it has access to all the same query 
  parameters as were found on the main database file.

  See the URI filename documentation for additional information. }
function sqlite3_uri_parameter(const zFilename : PChar; const zParam : PChar) :
  PChar; cdecl; external sqlite3_lib;
function sqlite3_uri_boolean(const zFile : PChar; const zParam : PChar; 
  bDefault : Integer) : Integer; cdecl; external sqlite3_lib;
function sqlite3_uri_int64(const zFilename : PChar; const zParam : PChar;
  bDflt : sqlite3_int64) : Integer; cdecl; external sqlite3_lib;
function sqlite3_uri_key(const zFilename : PChar; N : Integer) : PChar; cdecl;
  external sqlite3_lib;

{ These routines are available to custom VFS implementations for translating 
  filenames between the main database file, the journal file, and the WAL file.

  If F is the name of an sqlite database file, journal file, or WAL file passed 
  by the SQLite core into the VFS, then sqlite3_filename_database(F) returns the 
  name of the corresponding database file.

  If F is the name of an sqlite database file, journal file, or WAL file passed
  by the SQLite core into the VFS, or if F is a database filename obtained from 
  sqlite3_db_filename(), then sqlite3_filename_journal(F) returns the name of 
  the corresponding rollback journal file.

  If F is the name of an sqlite database file, journal file, or WAL file that 
  was passed by the SQLite core into the VFS, or if F is a database filename 
  obtained from sqlite3_db_filename(), then sqlite3_filename_wal(F) returns the 
  name of the corresponding WAL file.

  In all of the above, if F is not the name of a database, journal or WAL 
  filename passed into the VFS from the SQLite core and F is not the return 
  value from sqlite3_db_filename(), then the result is undefined and is likely a 
  memory access violation. }
function sqlite3_filename_database(const zFilename : PChar) : Pchar; cdecl;
  external sqlite3_lib;
function sqlite3_filename_journal(const zFilename : PChar) : PChar; cdecl;
  external sqlite3_lib;
function sqlite3_filename_wal(const zFilename : PChar) : PChar; cdecl;
  external sqlite3_lib;

{ If X is the name of a rollback or WAL-mode journal file that is passed into 
  the xOpen method of sqlite3_vfs, then sqlite3_database_file_object(X) returns 
  a pointer to the sqlite3_file object that represents the main database file.

  This routine is intended for use in custom VFS implementations only. It is not 
  a general-purpose interface. The argument sqlite3_file_object(X) must be a 
  filename pointer that has been passed into sqlite3_vfs.xOpen method where the 
  flags parameter to xOpen contains one of the bits SQLITE_OPEN_MAIN_JOURNAL or 
  SQLITE_OPEN_WAL. Any other use of this routine results in undefined and 
  probably undesirable behavior. }
function sqlite3_database_file_object(const zName : PChar) : psqlite3_file;
  cdecl; external sqlite3_lib;

{ These interfces are provided for use by VFS shim implementations and are not 
  useful outside of that context.

  The sqlite3_create_filename(D,J,W,N,P) allocates memory to hold a version of 
  database filename D with corresponding journal file J and WAL file W and with 
  N URI parameters key/values pairs in the array P. The result from 
  sqlite3_create_filename(D,J,W,N,P) is a pointer to a database filename that is 
  safe to pass to routines like:

    sqlite3_uri_parameter(),
    sqlite3_uri_boolean(),
    sqlite3_uri_int64(),
    sqlite3_uri_key(),
    sqlite3_filename_database(),
    sqlite3_filename_journal(), or
    sqlite3_filename_wal(). 

  If a memory allocation error occurs, sqlite3_create_filename() might return a 
  NULL pointer. The memory obtained from sqlite3_create_filename(X) must be 
  released by a corresponding call to sqlite3_free_filename(Y).

  The P parameter in sqlite3_create_filename(D,J,W,N,P) should be an array of 
  2*N pointers to strings. Each pair of pointers in this array corresponds to a 
  key and value for a query parameter. The P parameter may be a NULL pointer if
  N is zero. None of the 2*N pointers in the P array may be NULL pointers and 
  key pointers should not be empty strings. None of the D, J, or W parameters to 
  sqlite3_create_filename(D,J,W,N,P) may be NULL pointers, though they can be 
  empty strings.

  The sqlite3_free_filename(Y) routine releases a memory allocation previously 
  obtained from sqlite3_create_filename(). Invoking sqlite3_free_filename(Y) 
  where Y is a NULL pointer is a harmless no-op.

  If the Y parameter to sqlite3_free_filename(Y) is anything other than a NULL 
  pointer or a pointer previously acquired from sqlite3_create_filename(), then 
  bad things such as heap corruption or segfaults may occur. The value Y should 
  be used again after sqlite3_free_filename(Y) has been called. This means that 
  if the sqlite3_vfs.xOpen() method of a VFS has been called using Y, then the 
  corresponding [sqlite3_module.xClose() method should also be invoked prior to 
  calling sqlite3_free_filename(Y). }
function sqlite3_create_filename(const zDatabase : PChar; const zJournal : 
  PChar; const zWal : PChar; nParam : Integer; const azParam : PPChar) : PChar;
  cdecl; external sqlite3_lib;
procedure sqlite3_free_filename(databaseName : PChar); cdecl; 
  external sqlite3_lib;

{ If the most recent sqlite3_* API call associated with database connection D 
  failed, then the sqlite3_errcode(D) interface returns the numeric result code 
  or extended result code for that API call. The sqlite3_extended_errcode() 
  interface is the same except that it always returns the extended result code 
  even when extended result codes are disabled.

  The values returned by sqlite3_errcode() and/or sqlite3_extended_errcode() 
  might change with each API call. Except, there are some interfaces that are
  guaranteed to never change the value of the error code. The error-code 
  preserving interfaces are:

    sqlite3_errcode()
    sqlite3_extended_errcode()
    sqlite3_errmsg()
    sqlite3_errmsg16() 

  The sqlite3_errmsg() and sqlite3_errmsg16() return English-language text that 
  describes the error, as either UTF-8 or UTF-16 respectively. Memory to hold 
  the error message string is managed internally. The application does not need 
  to worry about freeing the result. However, the error string might be 
  overwritten or deallocated by subsequent calls to other SQLite interface 
  functions.

  The sqlite3_errstr() interface returns the English-language text that 
  describes the result code, as UTF-8. Memory to hold the error message string 
  is managed internally and must not be freed by the application.

  When the serialized threading mode is in use, it might be the case that a 
  second error occurs on a separate thread in between the time of the first 
  error and the call to these interfaces. When that happens, the second error 
  will be reported since these interfaces always report the most recent result.
  To avoid this, each thread can obtain exclusive use of the database connection 
  D by invoking sqlite3_mutex_enter(sqlite3_db_mutex(D)) before beginning to use 
  D and invoking sqlite3_mutex_leave(sqlite3_db_mutex(D)) after all calls to the 
  interfaces listed here are completed.

  If an interface fails with SQLITE_MISUSE, that means the interface was invoked 
  incorrectly by the application. In that case, the error code and message may 
  or may not be set. }
function sqlite3_errcode(db : psqlite3) : Integer; cdecl; external sqlite3_lib;
function sqlite3_extended_errcode(db : psqlite3) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_errmsg(db : psqlite3) : PChar; cdecl; external sqlite3_lib;
function sqlite3_errmsg16(db : psqlite3) : Pointer; cdecl; external sqlite3_lib;
function sqlite3_errstr(rc : Integer) : PChar; cdecl; external sqlite3_lib;

{ This interface allows the size of various constructs to be limited on a 
  connection by connection basis. The first parameter is the database connection 
  whose limit is to be set or queried. The second parameter is one of the limit 
  categories that define a class of constructs to be size limited. The third 
  parameter is the new limit for that construct.

  If the new limit is a negative number, the limit is unchanged. For each limit 
  category SQLITE_LIMIT_NAME there is a hard upper bound set at compile-time by 
  a C preprocessor macro called SQLITE_MAX_NAME. (The "_LIMIT_" in the name is 
  changed to "_MAX_".) Attempts to increase a limit above its hard upper bound 
  are silently truncated to the hard upper bound.

  Regardless of whether or not the limit was changed, the sqlite3_limit() 
  interface returns the prior value of the limit. Hence, to find the current 
  value of a limit without changing it, simply invoke this interface with the 
  third parameter set to -1.

  Run-time limits are intended for use in applications that manage both their 
  own internal database and also databases that are controlled by untrusted 
  external sources. An example application might be a web browser that has its 
  own databases for storing history and separate databases controlled by 
  JavaScript applications downloaded off the Internet. The internal databases 
  can be given the large, default limits. Databases managed by external sources 
  can be given much smaller limits designed to prevent a denial of service 
  attack. Developers might also want to use the sqlite3_set_authorizer() 
  interface to further control untrusted SQL. The size of the database created 
  by an untrusted script can be contained using the max_page_count PRAGMA.

  New run-time limit categories may be added in future releases. }
function sqlite3_limit(db : psqlite3; id : Integer; newVal : Integer) : Integer;
  cdecl; external sqlite3_lib;

{ To execute an SQL statement, it must first be compiled into a byte-code 
  program using one of these routines. Or, in other words, these routines are 
  constructors for the prepared statement object.

  The preferred routine to use is sqlite3_prepare_v2(). The sqlite3_prepare() 
  interface is legacy and should be avoided. sqlite3_prepare_v3() has an extra 
  "prepFlags" option that is used for special purposes.

  The use of the UTF-8 interfaces is preferred, as SQLite currently does all 
  parsing using UTF-8. The UTF-16 interfaces are provided as a convenience. The 
  UTF-16 interfaces work by converting the input text into UTF-8, then invoking 
  the corresponding UTF-8 interface.

  The first argument, "db", is a database connection obtained from a prior 
  successful call to sqlite3_open(), sqlite3_open_v2() or sqlite3_open16(). The 
  database connection must not have been closed.

  The second argument, "zSql", is the statement to be compiled, encoded as 
  either UTF-8 or UTF-16. The sqlite3_prepare(), sqlite3_prepare_v2(), and 
  sqlite3_prepare_v3() interfaces use UTF-8, and sqlite3_prepare16(), 
  sqlite3_prepare16_v2(), and sqlite3_prepare16_v3() use UTF-16.

  If the nByte argument is negative, then zSql is read up to the first zero 
  terminator. If nByte is positive, then it is the number of bytes read from 
  zSql. If nByte is zero, then no prepared statement is generated. If the caller 
  knows that the supplied string is nul-terminated, then there is a small 
  performance advantage to passing an nByte parameter that is the number of 
  bytes in the input string including the nul-terminator.

  If pzTail is not NULL then *pzTail is made to point to the first byte past the 
  end of the first SQL statement in zSql. These routines only compile the first 
  statement in zSql, so *pzTail is left pointing to what remains uncompiled.

  *ppStmt is left pointing to a compiled prepared statement that can be executed 
  using sqlite3_step(). If there is an error, *ppStmt is set to NULL. If the 
  input text contains no SQL (if the input is an empty string or a comment) then 
  *ppStmt is set to NULL. The calling procedure is responsible for deleting the 
  compiled SQL statement using sqlite3_finalize() after it has finished with it. 
  ppStmt may not be NULL.

  On success, the sqlite3_prepare() family of routines return SQLITE_OK; 
  otherwise an error code is returned.

  The sqlite3_prepare_v2(), sqlite3_prepare_v3(), sqlite3_prepare16_v2(), and 
  sqlite3_prepare16_v3() interfaces are recommended for all new programs. The 
  older interfaces (sqlite3_prepare() and sqlite3_prepare16()) are retained for 
  backwards compatibility, but their use is discouraged. In the "vX" interfaces, 
  the prepared statement that is returned (the sqlite3_stmt object) contains a 
  copy of the original SQL text. This causes the sqlite3_step() interface to 
  behave differently in three ways:

    If the database schema changes, instead of returning SQLITE_SCHEMA as it 
    always used to do, sqlite3_step() will automatically recompile the SQL 
    statement and try to run it again. As many as SQLITE_MAX_SCHEMA_RETRY 
    retries will occur before sqlite3_step() gives up and returns an error.

    When an error occurs, sqlite3_step() will return one of the detailed error 
    codes or extended error codes. The legacy behavior was that sqlite3_step() 
    would only return a generic SQLITE_ERROR result code and the application
    would have to make a second call to sqlite3_reset() in order to find the 
    underlying cause of the problem. With the "v2" prepare interfaces, the 
    underlying reason for the error is returned immediately.

    If the specific value bound to a host parameter in the WHERE clause might 
    influence the choice of query plan for a statement, then the statement will 
    be automatically recompiled, as if there had been a schema change, on the 
    first sqlite3_step() call following any change to the bindings of that 
    parameter. The specific value of a WHERE-clause parameter might influence 
    the choice of query plan if the parameter is the left-hand side of a LIKE or 
    GLOB operator or if the parameter is compared to an indexed column and the 
    SQLITE_ENABLE_STAT4 compile-time option is enabled.

  sqlite3_prepare_v3() differs from sqlite3_prepare_v2() only in having the 
  extra prepFlags parameter, which is a bit array consisting of zero or more of 
  the SQLITE_PREPARE_* flags. The sqlite3_prepare_v2() interface works exactly 
  the same as sqlite3_prepare_v3() with a zero prepFlags parameter. }
function sqlite3_prepare(db : psqlite3; const zSql : PChar; nByte : Integer;
  ppStmt : ppsqlite3_stmt; const pzTail : PPChar) : Integer; cdecl; 
  external sqlite3_lib;
function sqlite3_prepare_v2(db : psqlite3; const zSql : PChar; nByte : Integer;
  ppStmt : ppsqlite3_stmt; const pzTail : PPChar) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_prepare_v3(db : psqlite3; const zSql : PChar; nByte : Integer;
  prepFlags : Cardinal; ppStmt : ppsqlite3_stmt; const pzTail : PChar) : 
  Integer; cdecl; external sqlite3_lib;
function sqlite3_prepare16(db : psqlite3; const zSql : Pointer; nBytes : 
  Integer; ppStmt : ppsqlite3_stmt; const pzTail : PPointer) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_prepare16_v2(db : psqlite3; const zSql : Pointer; nByte : 
  Integer; ppStmt : ppsqlite3_stmt; const pzTail : PPointer) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_prepare16_v3(db : psqlite3; const zSql : Pointer; nByte :
  Integer; prepFlags : Cardinal; ppStmt : ppsqlite3_stmt; const pzTail :
  PPointer) : Integer; cdecl; external sqlite3_lib;

{ The sqlite3_sql(P) interface returns a pointer to a copy of the UTF-8 SQL text 
  used to create prepared statement P if P was created by sqlite3_prepare_v2(), 
  sqlite3_prepare_v3(), sqlite3_prepare16_v2(), or sqlite3_prepare16_v3(). The 
  sqlite3_expanded_sql(P) interface returns a pointer to a UTF-8 string 
  containing the SQL text of prepared statement P with bound parameters 
  expanded. The sqlite3_normalized_sql(P) interface returns a pointer to a UTF-8 
  string containing the normalized SQL text of prepared statement P. The 
  semantics used to normalize a SQL statement are unspecified and subject to 
  change. At a minimum, literal values will be replaced with suitable 
  placeholders.

  For example, if a prepared statement is created using the SQL text "SELECT 
  $abc,:xyz" and if parameter $abc is bound to integer 2345 and parameter :xyz 
  is unbound, then sqlite3_sql() will return the original string, 
  "SELECT $abc,:xyz" but sqlite3_expanded_sql() will return "SELECT 2345,NULL".

  The sqlite3_expanded_sql() interface returns NULL if insufficient memory is 
  available to hold the result, or if the result would exceed the the maximum 
  string length determined by the SQLITE_LIMIT_LENGTH.

  The SQLITE_TRACE_SIZE_LIMIT compile-time option limits the size of bound 
  parameter expansions. The SQLITE_OMIT_TRACE compile-time option causes 
  sqlite3_expanded_sql() to always return NULL.

  The strings returned by sqlite3_sql(P) and sqlite3_normalized_sql(P) are 
  managed by SQLite and are automatically freed when the prepared statement is 
  finalized. The string returned by sqlite3_expanded_sql(P), on the other hand, 
  is obtained from sqlite3_malloc() and must be free by the application by 
  passing it to sqlite3_free(). }
function sqlite3_sql(pStmt : psqlite3_stmt) : PChar; cdecl; 
  external sqlite3_lib;
function sqlite3_expanded_sql(pStmt : psqlite3_stmt) : PChar; cdecl;
  external sqlite3_lib;
function sqlite3_normalized_sql(pStmt : psqlite3_stmt) : PChar; cdecl;
  external sqlite3_lib;

{ The sqlite3_stmt_readonly(X) interface returns true (non-zero) if and only if 
  the prepared statement X makes no direct changes to the content of the 
  database file. 
  
  Transaction control statements such as BEGIN, COMMIT, ROLLBACK, SAVEPOINT, and 
  RELEASE cause sqlite3_stmt_readonly() to return true, since the statements 
  themselves do not actually modify the database but rather they control the 
  timing of when other statements modify the database. The ATTACH and DETACH 
  statements also cause sqlite3_stmt_readonly() to return true since, while 
  those statements change the configuration of a database connection, they do 
  not make changes to the content of the database files on disk. The 
  sqlite3_stmt_readonly() interface returns true for BEGIN since BEGIN merely 
  sets internal flags, but the BEGIN IMMEDIATE and BEGIN EXCLUSIVE commands do 
  touch the database and so sqlite3_stmt_readonly() returns false for those 
  commands. }
function sqlite3_stmt_readonly(pStmt : psqlite3_stmt) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_stmt_isexplain(S) interface returns 1 if the prepared statement S 
  is an EXPLAIN statement, or 2 if the statement S is an EXPLAIN QUERY PLAN. The 
  sqlite3_stmt_isexplain(S) interface returns 0 if S is an ordinary statement or 
  a NULL pointer. }
function sqlite3_stmt_isexplain(pStmt : psqlite3_stmt) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_stmt_busy(S) interface returns true (non-zero) if the prepared 
  statement S has been stepped at least once using sqlite3_step(S) but has 
  neither run to completion (returned SQLITE_DONE from sqlite3_step(S)) nor been 
  reset using sqlite3_reset(S). The sqlite3_stmt_busy(S) interface returns false 
  if S is a NULL pointer. If S is not a NULL pointer and is not a pointer to a 
  valid prepared statement object, then the behavior is undefined and probably 
  undesirable.

  This interface can be used in combination sqlite3_next_stmt() to locate all 
  prepared statements associated with a database connection that are in need of 
  being reset. This can be used, for example, in diagnostic routines to search 
  for prepared statements that are holding a transaction open. }
function sqlite3_stmt_busy(pStmt : psqlite3_stmt) : Integer; cdecl;
  external sqlite3_lib;

{ In the SQL statement text input to sqlite3_prepare_v2() and its variants, 
  literals may be replaced by a parameter that matches one of following 
  templates:

    ?
    ?NNN
    :VVV
    @VVV
    $VVV 

  In the templates above, NNN represents an integer literal, and VVV represents 
  an alphanumeric identifier. The values of these parameters (also called "host 
  parameter names" or "SQL parameters") can be set using the sqlite3_bind_*() 
  routines defined here.

  The first argument to the sqlite3_bind_*() routines is always a pointer to the 
  sqlite3_stmt object returned from sqlite3_prepare_v2() or its variants.

  The second argument is the index of the SQL parameter to be set. The leftmost 
  SQL parameter has an index of 1. When the same named SQL parameter is used 
  more than once, second and subsequent occurrences have the same index as the 
  first occurrence. The index for named parameters can be looked up using the 
  sqlite3_bind_parameter_index() API if desired. The index for "?NNN" parameters 
  is the value of NNN. The NNN value must be between 1 and the sqlite3_limit() 
  parameter SQLITE_LIMIT_VARIABLE_NUMBER (default value: 32766).

  The third argument is the value to bind to the parameter. If the third 
  parameter to sqlite3_bind_text() or sqlite3_bind_text16() or 
  sqlite3_bind_blob() is a NULL pointer then the fourth parameter is ignored and 
  the end result is the same as sqlite3_bind_null(). If the third parameter to 
  sqlite3_bind_text() is not NULL, then it should be a pointer to well-formed 
  UTF8 text. If the third parameter to sqlite3_bind_text16() is not NULL, then 
  it should be a pointer to well-formed UTF16 text. If the third parameter to 
  sqlite3_bind_text64() is not NULL, then it should be a pointer to a 
  well-formed unicode string that is either UTF8 if the sixth parameter is 
  SQLITE_UTF8, or UTF16 otherwise.

  The byte-order of UTF16 input text is determined by the byte-order mark (BOM, 
  U+FEFF) found in first character, which is removed, or in the absence of a BOM 
  the byte order is the native byte order of the host machine for 
  sqlite3_bind_text16() or the byte order specified in the 6th parameter for 
  sqlite3_bind_text64(). If UTF16 input text contains invalid unicode 
  characters, then SQLite might change those invalid characters into the unicode 
  replacement character: U+FFFD.

  In those routines that have a fourth argument, its value is the number of 
  bytes in the parameter. To be clear: the value is the number of bytes in the 
  value, not the number of characters. If the fourth parameter to 
  sqlite3_bind_text() or sqlite3_bind_text16() is negative, then the length of 
  the string is the number of bytes up to the first zero terminator. If the 
  fourth parameter to sqlite3_bind_blob() is negative, then the behavior is 
  undefined. If a non-negative fourth parameter is provided to 
  sqlite3_bind_text() or sqlite3_bind_text16() or sqlite3_bind_text64() then 
  that parameter must be the byte offset where the NUL terminator would occur 
  assuming the string were NUL terminated. If any NUL characters occurs at byte 
  offsets less than the value of the fourth parameter then the resulting string 
  value will contain embedded NULs. The result of expressions involving strings 
  with embedded NULs is undefined.

  The fifth argument to the BLOB and string binding interfaces is a destructor 
  used to dispose of the BLOB or string after SQLite has finished with it. The 
  destructor is called to dispose of the BLOB or string even if the call to the 
  bind API fails, except the destructor is not called if the third parameter is 
  a NULL pointer or the fourth parameter is negative. If the fifth argument is 
  the special value SQLITE_STATIC, then SQLite assumes that the information is 
  in static, unmanaged space and does not need to be freed. If the fifth 
  argument has the value SQLITE_TRANSIENT, then SQLite makes its own private 
  copy of the data immediately, before the sqlite3_bind_*() routine returns.

  The sixth argument to sqlite3_bind_text64() must be one of SQLITE_UTF8, 
  SQLITE_UTF16, SQLITE_UTF16BE, or SQLITE_UTF16LE to specify the encoding of the 
  text in the third parameter. If the sixth argument to sqlite3_bind_text64() is 
  not one of the allowed values shown above, or if the text encoding is 
  different from the encoding specified by the sixth parameter, then the 
  behavior is undefined.

  The sqlite3_bind_zeroblob() routine binds a BLOB of length N that is filled 
  with zeroes. A zeroblob uses a fixed amount of memory (just an integer to hold 
  its size) while it is being processed. Zeroblobs are intended to serve as 
  placeholders for BLOBs whose content is later written using incremental BLOB 
  I/O routines. A negative value for the zeroblob results in a zero-length BLOB.

  The sqlite3_bind_pointer(S,I,P,T,D) routine causes the I-th parameter in 
  prepared statement S to have an SQL value of NULL, but to also be associated 
  with the pointer P of type T. D is either a NULL pointer or a pointer to a 
  destructor function for P. SQLite will invoke the destructor D with a single 
  argument of P when it is finished using P. The T parameter should be a static 
  string, preferably a string literal. The sqlite3_bind_pointer() routine is 
  part of the pointer passing interface added for SQLite 3.20.0.

  If any of the sqlite3_bind_*() routines are called with a NULL pointer for the 
  prepared statement or with a prepared statement for which sqlite3_step() has 
  been called more recently than sqlite3_reset(), then the call will return 
  SQLITE_MISUSE. If any sqlite3_bind_() routine is passed a prepared statement 
  that has been finalized, the result is undefined and probably harmful.

  Bindings are not cleared by the sqlite3_reset() routine. Unbound parameters 
  are interpreted as NULL.

  The sqlite3_bind_* routines return SQLITE_OK on success or an error code if 
  anything goes wrong. SQLITE_TOOBIG might be returned if the size of a string 
  or BLOB exceeds limits imposed by sqlite3_limit(SQLITE_LIMIT_LENGTH) or 
  SQLITE_MAX_LENGTH. SQLITE_RANGE is returned if the parameter index is out of 
  range. SQLITE_NOMEM is returned if malloc() fails. }
function sqlite3_bind_blob(pStmt : psqlite3_stmt; i : Integer; const zData :
  Pointer; nData : Integer; xDel : xDel_calback) : Integer; cdecl; 
  external sqlite3_lib;
function sqlite3_bind_blob64(pStmt : psqlite3_stmt; i : Integer; const zData :
  Pointer; nData : sqlite3_uint64; xDel : xDel_calback) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_bind_double(pStmt : psqlite3_stmt; i : Integer; rValue :
  Double) : Integer; cdecl; external sqlite3_lib;
function sqlite3_bind_int(pStmt : psqlite3_stmt; i : Integer; iValue : Integer)
  : Integer; cdecl; external sqlite3_lib;
function sqlite3_bind_int64(pStmt : psqlite3_stmt; i : Integer; iValue : 
  sqlite3_int64) : Integer; cdecl; external sqlite3_lib;
function sqlite3_bind_null(pStmt : psqlite3_stmt; i : Integer) : Integer;
  cdecl; external sqlite3_lib;
function sqlite3_bind_text(pStmt : psqlite3_stmt; i : Integer; const zData :
  PChar; nData : Integer; xDel : xDel_calback) : Integer; cdecl; 
  external sqlite3_lib;
function sqlite3_bind_text16(pStmt : psqlite3_stmt; i : Integer; const zData :
  Pointer; nData : Integer; xDel : xDel_calback) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_bind_text64(pStmt : psqlite3_stmt; i : Integer; const zData :
  PChar; nData : sqlite3_uint64; xDel : xDel_calback; encoding : Byte) : 
  Integer; cdecl; external sqlite3_lib;
function sqlite3_bind_value(pStmt : psqlite3_stmt; i : Integer; const pValue :
  psqlite3_value) : Integer; cdecl; external sqlite3_lib;
function sqlite3_bind_pointer(pStmt : psqlite3_stmt; i : Integer; pPtr : 
  Pointer; const zPTtype : PChar; xDestructor : xDestructor_callback) : Integer;
  cdecl; external sqlite3_lib;
function sqlite3_bind_zeroblob(pStmt : psqlite3_stmt; i : Integer; n : Integer) 
  : Integer; cdecl; external sqlite3_lib;
function sqlite3_bind_zeroblob64(pStmt : psqlite3_stmt; i : Integer; n :
  sqlite3_uint64) : Integer; cdecl; external sqlite3_lib;

{ This routine can be used to find the number of SQL parameters in a prepared 
  statement. SQL parameters are tokens of the form "?", "?NNN", ":AAA", "$AAA", 
  or "@AAA" that serve as placeholders for values that are bound to the 
  parameters at a later time.

  This routine actually returns the index of the largest (rightmost) parameter. 
  For all forms except ?NNN, this will correspond to the number of unique 
  parameters. If parameters of the ?NNN form are used, there may be gaps in the 
  list. }
function sqlite3_bind_parameter_count(pStmt : psqlite3_stmt) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_bind_parameter_name(P,N) interface returns the name of the N-th 
  SQL parameter in the prepared statement P. SQL parameters of the form "?NNN" 
  or ":AAA" or "@AAA" or "$AAA" have a name which is the string "?NNN" or ":AAA" 
  or "@AAA" or "$AAA" respectively. In other words, the initial ":" or "$" or 
  "@" or "?" is included as part of the name. Parameters of the form "?" without 
  a following integer have no name and are referred to as "nameless" or 
  "anonymous parameters".

  The first host parameter has an index of 1, not 0.

  If the value N is out of range or if the N-th parameter is nameless, then NULL 
  is returned. The returned string is always in UTF-8 encoding even if the named 
  parameter was originally specified as UTF-16 in sqlite3_prepare16(), 
  sqlite3_prepare16_v2(), or sqlite3_prepare16_v3(). } 
function sqlite3_bind_parameter_name(pStmt : psqlite3_stmt; i : Integer) : 
  PChar; cdecl; external sqlite3_lib;

{ Return the index of an SQL parameter given its name. The index value returned 
  is suitable for use as the second parameter to sqlite3_bind(). A zero is 
  returned if no matching parameter is found. The parameter name must be given 
  in UTF-8 even if the original statement was prepared from UTF-16 text using 
  sqlite3_prepare16_v2() or sqlite3_prepare16_v3(). }
function sqlite3_bind_parameter_index(pStmt : psqlite3_stmt; const zName : 
  PChar) : Integer; cdecl; external sqlite3_lib;

{ Contrary to the intuition of many, sqlite3_reset() does not reset the bindings 
  on a prepared statement. Use this routine to reset all host parameters to 
  NULL. }
function sqlite3_clear_bindings(pStmt : psqlite3_stmt) : Integer; cdecl;
  external sqlite3_lib;

{ Return the number of columns in the result set returned by the prepared 
  statement. If this routine returns 0, that means the prepared statement 
  returns no data (for example an UPDATE). However, just because this routine 
  returns a positive number does not mean that one or more rows of data will be 
  returned. A SELECT statement will always have a positive 
  sqlite3_column_count() but depending on the WHERE clause constraints and the 
  table content, it might return no rows. }
function sqlite3_column_count(pStmt : psqlite3_stmt) : Integer; cdecl;
  external sqlite3_lib;

{ These routines return the name assigned to a particular column in the result 
  set of a SELECT statement. The sqlite3_column_name() interface returns a 
  pointer to a zero-terminated UTF-8 string and sqlite3_column_name16() returns 
  a pointer to a zero-terminated UTF-16 string. The first parameter is the 
  prepared statement that implements the SELECT statement. The second parameter 
  is the column number. The leftmost column is number 0.

  The returned string pointer is valid until either the prepared statement is 
  destroyed by sqlite3_finalize() or until the statement is automatically 
  reprepared by the first call to sqlite3_step() for a particular run or until 
  the next call to sqlite3_column_name() or sqlite3_column_name16() on the same 
  column.

  If sqlite3_malloc() fails during the processing of either routine (for example 
  during a conversion from UTF-8 to UTF-16) then a NULL pointer is returned.

  The name of a result column is the value of the "AS" clause for that column, 
  if there is an AS clause. If there is no AS clause then the name of the column 
  is unspecified and may change from one release of SQLite to the next. }
function sqlite3_column_name(pStmt : psqlite3_stmt; N : Integer) : PChar; cdecl;
  external sqlite3_lib;
function sqlite3_column_name16(pStmt : psqlite3_stmt; N : Integer) : Pointer;
  cdecl; external sqlite3_lib;

{ These routines provide a means to determine the database, table, and table 
  column that is the origin of a particular result column in SELECT statement. 
  The name of the database or table or column can be returned as either a UTF-8 
  or UTF-16 string. The _database_ routines return the database name, the 
  _table_ routines return the table name, and the origin_ routines return the 
  column name. The returned string is valid until the prepared statement is 
  destroyed using sqlite3_finalize() or until the statement is automatically 
  reprepared by the first call to sqlite3_step() for a particular run or until 
  the same information is requested again in a different encoding.

  The names returned are the original un-aliased names of the database, table, 
  and column.

  The first argument to these interfaces is a prepared statement. These 
  functions return information about the Nth result column returned by the 
  statement, where N is the second function argument. The left-most column is 
  column 0 for these routines.

  If the Nth column returned by the statement is an expression or subquery and 
  is not a column value, then all of these functions return NULL. These routines 
  might also return NULL if a memory allocation error occurs. Otherwise, they 
  return the name of the attached database, table, or column that query result 
  column was extracted from.

  As with all other SQLite APIs, those whose names end with "16" return UTF-16 
  encoded strings and the other functions return UTF-8.

  These APIs are only available if the library was compiled with the 
  SQLITE_ENABLE_COLUMN_METADATA C-preprocessor symbol.

  If two or more threads call one or more column metadata interfaces for the 
  same prepared statement and result column at the same time then the results 
  are undefined. }
function sqlite3_column_database_name(pStmt : psqlite3_stmt; N : Integer) : 
  PChar; cdecl; external sqlite3_lib;
function sqlite3_column_database_name16(pStmt : psqlite3_stmt; N : Integer) :
  Pointer; cdecl; external sqlite3_lib;
function sqlite3_column_table_name(pStmt : psqlite3_stmt; N : Integer) : PChar;
  cdecl; external sqlite3_lib;
function sqlite3_column_table_name16(pStmt : psqlite3_stmt; N : Integer) :
  Pointer; cdecl; external sqlite3_lib;
function sqlite3_column_origin_name(pStmt : psqlite3_stmt; N : Integer) : PChar;
  cdecl; external sqlite3_lib;
function sqlite3_column_origin_name16(pStmt : psqlite3_stmt; N : Integer) : 
  Pointer; cdecl; external sqlite3_lib;

{ The first parameter is a prepared statement. If this statement is a SELECT 
  statement and the Nth column of the returned result set of that SELECT is a 
  table column (not an expression or subquery) then the declared type of the 
  table column is returned. If the Nth column of the result set is an expression 
  or subquery, then a NULL pointer is returned. The returned string is always 
  UTF-8 encoded.
  
  SQLite uses dynamic run-time typing. So just because a column is declared to 
  contain a particular type does not mean that the data stored in that column is 
  of the declared type. SQLite is strongly typed, but the typing is dynamic not 
  static. Type is associated with individual values, not with the containers 
  used to hold those values. }
function sqlite3_column_decltype(pStmt : psqlite3_stmt; N : Integer) : PChar;
  cdecl; external sqlite3_lib;
function sqlite3_column_decltype16(pStmt : psqlite3_stmt; N : Integer) : 
  Pointer; cdecl; external sqlite3_lib;

{ After a prepared statement has been prepared using any of 
  sqlite3_prepare_v2(), sqlite3_prepare_v3(), sqlite3_prepare16_v2(), or 
  sqlite3_prepare16_v3() or one of the legacy interfaces sqlite3_prepare() or 
  sqlite3_prepare16(), this function must be called one or more times to 
  evaluate the statement.

  The details of the behavior of the sqlite3_step() interface depend on whether 
  the statement was prepared using the newer "vX" interfaces 
  sqlite3_prepare_v3(), sqlite3_prepare_v2(), sqlite3_prepare16_v3(), 
  sqlite3_prepare16_v2() or the older legacy interfaces sqlite3_prepare() and 
  sqlite3_prepare16(). The use of the new "vX" interface is recommended for new 
  applications but the legacy interface will continue to be supported.

  In the legacy interface, the return value will be either SQLITE_BUSY, 
  SQLITE_DONE, SQLITE_ROW, SQLITE_ERROR, or SQLITE_MISUSE. With the "v2" 
  interface, any of the other result codes or extended result codes might be 
  returned as well.

  SQLITE_BUSY means that the database engine was unable to acquire the database 
  locks it needs to do its job. If the statement is a COMMIT or occurs outside 
  of an explicit transaction, then you can retry the statement. If the statement 
  is not a COMMIT and occurs within an explicit transaction then you should 
  rollback the transaction before continuing.

  SQLITE_DONE means that the statement has finished executing successfully. 
  sqlite3_step() should not be called again on this virtual machine without 
  first calling sqlite3_reset() to reset the virtual machine back to its initial 
  state.

  If the SQL statement being executed returns any data, then SQLITE_ROW is 
  returned each time a new row of data is ready for processing by the caller. 
  The values may be accessed using the column access functions. sqlite3_step() 
  is called again to retrieve the next row of data.

  SQLITE_ERROR means that a run-time error (such as a constraint violation) has 
  occurred. sqlite3_step() should not be called again on the VM. More 
  information may be found by calling sqlite3_errmsg(). With the legacy 
  interface, a more specific error code (for example, SQLITE_INTERRUPT, 
  SQLITE_SCHEMA, SQLITE_CORRUPT, and so forth) can be obtained by calling 
  sqlite3_reset() on the prepared statement. In the "v2" interface, the more 
  specific error code is returned directly by sqlite3_step().

  SQLITE_MISUSE means that the this routine was called inappropriately. Perhaps 
  it was called on a prepared statement that has already been finalized or on 
  one that had previously returned SQLITE_ERROR or SQLITE_DONE. Or it could be 
  the case that the same database connection is being used by two or more 
  threads at the same moment in time.

  For all versions of SQLite up to and including 3.6.23.1, a call to 
  sqlite3_reset() was required after sqlite3_step() returned anything other than 
  SQLITE_ROW before any subsequent invocation of sqlite3_step(). Failure to 
  reset the prepared statement using sqlite3_reset() would result in an 
  SQLITE_MISUSE return from sqlite3_step(). But after version 3.6.23.1 
  (2010-03-26, sqlite3_step() began calling sqlite3_reset() automatically in 
  this circumstance rather than returning SQLITE_MISUSE. This is not considered 
  a compatibility break because any application that ever receives an 
  SQLITE_MISUSE error is broken by definition. The SQLITE_OMIT_AUTORESET 
  compile-time option can be used to restore the legacy behavior.

  Goofy Interface Alert: In the legacy interface, the sqlite3_step() API always 
  returns a generic error code, SQLITE_ERROR, following any error other than 
  SQLITE_BUSY and SQLITE_MISUSE. You must call sqlite3_reset() or 
  sqlite3_finalize() in order to find one of the specific error codes that 
  better describes the error. We admit that this is a goofy design. The problem 
  has been fixed with the "v2" interface. If you prepare all of your SQL 
  statements using sqlite3_prepare_v3() or sqlite3_prepare_v2() or 
  sqlite3_prepare16_v2() or sqlite3_prepare16_v3() instead of the legacy 
  sqlite3_prepare() and sqlite3_prepare16() interfaces, then the more specific 
  error codes are returned directly by sqlite3_step(). The use of the "vX" 
  interfaces is recommended. }
function sqlite3_step(pStmt : psqlite3_stmt) : Integer; cdecl; 
  external sqlite3_lib;

{ The sqlite3_data_count(P) interface returns the number of columns in the 
  current row of the result set of prepared statement P. If prepared statement P 
  does not have results ready to return (via calls to the sqlite3_column() 
  family of interfaces) then sqlite3_data_count(P) returns 0. The 
  sqlite3_data_count(P) routine also returns 0 if P is a NULL pointer. The 
  sqlite3_data_count(P) routine returns 0 if the previous call to 
  sqlite3_step(P) returned SQLITE_DONE. The sqlite3_data_count(P) will return 
  non-zero if previous call to sqlite3_step(P) returned SQLITE_ROW, except in 
  the case of the PRAGMA incremental_vacuum where it always returns zero since 
  each step of that multi-step pragma returns 0 columns of data. }
function sqlite3_data_count(pStmt : sqlite3_stmt) : Integer; cdecl;
  external sqlite3_lib;

{ sqlite3_column_blob	      →	BLOB result
  sqlite3_column_double	    →	REAL result
  sqlite3_column_int	      →	32-bit INTEGER result
  sqlite3_column_int64	    →	64-bit INTEGER result
  sqlite3_column_text	      →	UTF-8 TEXT result
  sqlite3_column_text16	    →	UTF-16 TEXT result
  sqlite3_column_value	    →	The result as an unprotected sqlite3_value object.
      
  sqlite3_column_bytes	    →	Size of a BLOB or a UTF-8 TEXT result in bytes
  sqlite3_column_bytes16   	→  	Size of UTF-16 TEXT in bytes
  sqlite3_column_type	      →	Default datatype of the result
  
  These routines return information about a single column of the current result 
  row of a query. In every case the first argument is a pointer to the prepared 
  statement that is being evaluated (the sqlite3_stmt* that was returned from 
  sqlite3_prepare_v2() or one of its variants) and the second argument is the 
  index of the column for which information should be returned. The leftmost 
  column of the result set has the index 0. The number of columns in the result 
  can be determined using sqlite3_column_count().

  If the SQL statement does not currently point to a valid row, or if the column 
  index is out of range, the result is undefined. These routines may only be 
  called when the most recent call to sqlite3_step() has returned SQLITE_ROW and 
  neither sqlite3_reset() nor sqlite3_finalize() have been called subsequently. 
  If any of these routines are called after sqlite3_reset() or 
  sqlite3_finalize() or after sqlite3_step() has returned something other than 
  SQLITE_ROW, the results are undefined. If sqlite3_step() or sqlite3_reset() or 
  sqlite3_finalize() are called from a different thread while any of these 
  routines are pending, then the results are undefined.

  The first six interfaces (_blob, _double, _int, _int64, _text, and _text16) 
  each return the value of a result column in a specific data format. If the 
  result column is not initially in the requested format (for example, if the 
  query returns an integer but the sqlite3_column_text() interface is used to 
  extract the value) then an automatic type conversion is performed.

  The sqlite3_column_type() routine returns the datatype code for the initial 
  data type of the result column. The returned value is one of SQLITE_INTEGER, 
  SQLITE_FLOAT, SQLITE_TEXT, SQLITE_BLOB, or SQLITE_NULL. The return value of 
  sqlite3_column_type() can be used to decide which of the first six interface 
  should be used to extract the column value. The value returned by 
  sqlite3_column_type() is only meaningful if no automatic type conversions have 
  occurred for the value in question. After a type conversion, the result of 
  calling sqlite3_column_type() is undefined, though harmless. Future versions 
  of SQLite may change the behavior of sqlite3_column_type() following a type 
  conversion.

  If the result is a BLOB or a TEXT string, then the sqlite3_column_bytes() or 
  sqlite3_column_bytes16() interfaces can be used to determine the size of that 
  BLOB or string.

  If the result is a BLOB or UTF-8 string then the sqlite3_column_bytes() 
  routine returns the number of bytes in that BLOB or string. If the result is a 
  UTF-16 string, then sqlite3_column_bytes() converts the string to UTF-8 and 
  then returns the number of bytes. If the result is a numeric value then 
  sqlite3_column_bytes() uses sqlite3_snprintf() to convert that value to a 
  UTF-8 string and returns the number of bytes in that string. If the result is 
  NULL, then sqlite3_column_bytes() returns zero.

  If the result is a BLOB or UTF-16 string then the sqlite3_column_bytes16() 
  routine returns the number of bytes in that BLOB or string. If the result is a 
  UTF-8 string, then sqlite3_column_bytes16() converts the string to UTF-16 and 
  then returns the number of bytes. If the result is a numeric value then 
  sqlite3_column_bytes16() uses sqlite3_snprintf() to convert that value to a 
  UTF-16 string and returns the number of bytes in that string. If the result is 
  NULL, then sqlite3_column_bytes16() returns zero.

  The values returned by sqlite3_column_bytes() and sqlite3_column_bytes16() do 
  not include the zero terminators at the end of the string. For clarity: the 
  values returned by sqlite3_column_bytes() and sqlite3_column_bytes16() are the 
  number of bytes in the string, not the number of characters.

  Strings returned by sqlite3_column_text() and sqlite3_column_text16(), even 
  empty strings, are always zero-terminated. The return value from 
  sqlite3_column_blob() for a zero-length BLOB is a NULL pointer.

  Warning: The object returned by sqlite3_column_value() is an unprotected 
  sqlite3_value object. In a multithreaded environment, an unprotected 
  sqlite3_value object may only be used safely with sqlite3_bind_value() and 
  sqlite3_result_value(). If the unprotected sqlite3_value object returned by 
  sqlite3_column_value() is used in any other way, including calls to routines 
  like sqlite3_value_int(), sqlite3_value_text(), or sqlite3_value_bytes(), the 
  behavior is not threadsafe. Hence, the sqlite3_column_value() interface is 
  normally only useful within the implementation of application-defined SQL 
  functions or virtual tables, not within top-level application code. }
function sqlite3_column_blob(pStmt : psqlite3_stmt; iCol : Integer) : Pointer;
  cdecl; external sqlite3_lib;
function sqlite3_column_double(pStmt : psqlite3_stmt; iCol : Integer) : Double;
  cdecl; external sqlite3_lib;
function sqlite3_column_int(pStmt : psqlite3_stmt; iCol : Integer) : Integer;
  cdecl; external sqlite3_lib;
function sqlite3_column_int64(pStmt : psqlite3_stmt; iCol : Integer) :
  sqlite3_int64; cdecl; external sqlite3_lib;
function sqlite3_column_text(pStmt : psqlite3_stmt; iCol : Integer) : PByte;
  cdecl; external sqlite3_lib;
function sqlite3_column_text16(pStmt : psqlite3_stmt; iCol : Integer) : Pointer;
  cdecl; external sqlite3_lib;
function sqlite3_column_value(pStmt : psqlite3_stmt; iCol : Integer) :
  psqlite3_value; cdecl; external sqlite3_lib;
function sqlite3_column_bytes(pStmt : psqlite3_stmt; iCol : Integer) : Integer;
  cdecl; external sqlite3_lib;
function sqlite3_column_bytes16(pStmt : psqlite3_stmt; iCol : Integer) : 
  Integer; cdecl; external sqlite3_lib;
function sqlite3_column_type(pStmt : psqlite3_stmt; iCol : Integer) : Integer;
  cdecl; external sqlite3_lib;

{ The sqlite3_finalize() function is called to delete a prepared statement. If 
  the most recent evaluation of the statement encountered no errors or if the 
  statement is never been evaluated, then sqlite3_finalize() returns SQLITE_OK. 
  If the most recent evaluation of statement S failed, then sqlite3_finalize(S) 
  returns the appropriate error code or extended error code.

  The sqlite3_finalize(S) routine can be called at any point during the life 
  cycle of prepared statement S: before statement S is ever evaluated, after one 
  or more calls to sqlite3_reset(), or after any call to sqlite3_step() 
  regardless of whether or not the statement has completed execution.

  Invoking sqlite3_finalize() on a NULL pointer is a harmless no-op.

  The application must finalize every prepared statement in order to avoid 
  resource leaks. It is a grievous error for the application to try to use a 
  prepared statement after it has been finalized. Any use of a prepared 
  statement after it has been finalized can result in undefined and undesirable 
  behavior such as segfaults and heap corruption. }
function sqlite3_finalize(pStmt : psqlite3_stmt) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_reset() function is called to reset a prepared statement object 
  back to its initial state, ready to be re-executed. Any SQL statement 
  variables that had values bound to them using the sqlite3_bind_*() API retain 
  their values. Use sqlite3_clear_bindings() to reset the bindings.

  The sqlite3_reset(S) interface resets the prepared statement S back to the 
  beginning of its program.

  If the most recent call to sqlite3_step(S) for the prepared statement S 
  returned SQLITE_ROW or SQLITE_DONE, or if sqlite3_step(S) has never before 
  been called on S, then sqlite3_reset(S) returns SQLITE_OK.

  If the most recent call to sqlite3_step(S) for the prepared statement S 
  indicated an error, then sqlite3_reset(S) returns an appropriate error code.

  The sqlite3_reset(S) interface does not change the values of any bindings on 
  the prepared statement S. }
function sqlite3_reset(pStmt : psqlite3_stmt) : Integer; cdecl; 
  external sqlite3_lib;

{ These functions (collectively known as "function creation routines") are used 
  to add SQL functions or aggregates or to redefine the behavior of existing SQL 
  functions or aggregates. The only differences between the three 
  "sqlite3_create_function*" routines are the text encoding expected for the 
  second parameter (the name of the function being created) and the presence or 
  absence of a destructor callback for the application data pointer. Function 
  sqlite3_create_window_function() is similar, but allows the user to supply the 
  extra callback functions needed by aggregate window functions.

  The first parameter is the database connection to which the SQL function is to 
  be added. If an application uses more than one database connection then 
  application-defined SQL functions must be added to each database connection 
  separately.

  The second parameter is the name of the SQL function to be created or 
  redefined. The length of the name is limited to 255 bytes in a UTF-8 
  representation, exclusive of the zero-terminator. Note that the name length 
  limit is in UTF-8 bytes, not characters nor UTF-16 bytes. Any attempt to 
  create a function with a longer name will result in SQLITE_MISUSE being 
  returned.

  The third parameter (nArg) is the number of arguments that the SQL function or 
  aggregate takes. If this parameter is -1, then the SQL function or aggregate 
  may take any number of arguments between 0 and the limit set by 
  sqlite3_limit(SQLITE_LIMIT_FUNCTION_ARG). If the third parameter is less than 
  -1 or greater than 127 then the behavior is undefined.

  The fourth parameter, eTextRep, specifies what text encoding this SQL function 
  prefers for its parameters. The application should set this parameter to 
  SQLITE_UTF16LE if the function implementation invokes sqlite3_value_text16le() 
  on an input, or SQLITE_UTF16BE if the implementation invokes 
  sqlite3_value_text16be() on an input, or SQLITE_UTF16 if 
  sqlite3_value_text16() is used, or SQLITE_UTF8 otherwise. The same SQL 
  function may be registered multiple times using different preferred text 
  encodings, with different implementations for each encoding. When multiple 
  implementations of the same function are available, SQLite will pick the one 
  that involves the least amount of data conversion.

  The fourth parameter may optionally be ORed with SQLITE_DETERMINISTIC to 
  signal that the function will always return the same result given the same 
  inputs within a single SQL statement. Most SQL functions are deterministic. 
  The built-in random() SQL function is an example of a function that is not 
  deterministic. The SQLite query planner is able to perform additional 
  optimizations on deterministic functions, so use of the SQLITE_DETERMINISTIC 
  flag is recommended where possible.

  The fourth parameter may also optionally include the SQLITE_DIRECTONLY flag, 
  which if present prevents the function from being invoked from within VIEWs, 
  TRIGGERs, CHECK constraints, generated column expressions, index expressions, 
  or the WHERE clause of partial indexes.

  For best security, the SQLITE_DIRECTONLY flag is recommended for all 
  application-defined SQL functions that do not need to be used inside of 
  triggers, view, CHECK constraints, or other elements of the database schema. 
  This flags is especially recommended for SQL functions that have side effects 
  or reveal internal application state. Without this flag, an attacker might be 
  able to modify the schema of a database file to include invocations of the 
  function with parameters chosen by the attacker, which the application will 
  then execute when the database file is opened and read.

  The fifth parameter is an arbitrary pointer. The implementation of the 
  function can gain access to this pointer using sqlite3_user_data().

  The sixth, seventh and eighth parameters passed to the three 
  "sqlite3_create_function*" functions, xFunc, xStep and xFinal, are pointers to 
  C-language functions that implement the SQL function or aggregate. A scalar 
  SQL function requires an implementation of the xFunc callback only; NULL 
  pointers must be passed as the xStep and xFinal parameters. An aggregate SQL 
  function requires an implementation of xStep and xFinal and NULL pointer must 
  be passed for xFunc. To delete an existing SQL function or aggregate, pass 
  NULL pointers for all three function callbacks.

  The sixth, seventh, eighth and ninth parameters (xStep, xFinal, xValue and 
  xInverse) passed to sqlite3_create_window_function are pointers to C-language 
  callbacks that implement the new function. xStep and xFinal must both be 
  non-NULL. xValue and xInverse may either both be NULL, in which case a regular 
  aggregate function is created, or must both be non-NULL, in which case the new 
  function may be used as either an aggregate or aggregate window function. More 
  details regarding the implementation of aggregate window functions are 
  available here.

  If the final parameter to sqlite3_create_function_v2() or 
  sqlite3_create_window_function() is not NULL, then it is destructor for the 
  application data pointer. The destructor is invoked when the function is 
  deleted, either by being overloaded or when the database connection closes. 
  The destructor is also invoked if the call to sqlite3_create_function_v2() 
  fails. When the destructor callback is invoked, it is passed a single argument 
  which is a copy of the application data pointer which was the fifth parameter 
  to sqlite3_create_function_v2().

  It is permitted to register multiple implementations of the same functions 
  with the same name but with either differing numbers of arguments or differing 
  preferred text encodings. SQLite will use the implementation that most closely 
  matches the way in which the SQL function is used. A function implementation 
  with a non-negative nArg parameter is a better match than a function 
  implementation with a negative nArg. A function where the preferred text 
  encoding matches the database encoding is a better match than a function where 
  the encoding is different. A function where the encoding difference is between 
  UTF16le and UTF16be is a closer match than a function where the encoding 
  difference is between UTF8 and UTF16.

  Built-in functions may be overloaded by new application-defined functions.

  An application-defined function is permitted to call other SQLite interfaces. 
  However, such calls must not close the database connection nor finalize or 
  reset the prepared statement in which the function is running. }
function sqlite3_create_function(db : psqlite3; const zFunctionName : PChar; 
  nArg : Integer; eTextRep : Integer; pApp : Pointer; xFunc : xFunc_callback;
  xStep : xStep_callback; xFinal : xFinal_callback) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_create_function16(db : sqlite3; const zFunctionName : Pointer;
  nArg : Integer; eTextRep : Integer; pApp : Pointer; xFunc : xFunc_callback;
  xStep : xStep_callback; xFinal : xFinal_callback) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_create_function_v2(db : psqlite3; const zFunctionName : PChar;
  nArg : Integer; eTextRep : Integer; pApp : Pointer; xFunc : xFunc_callback;
  xStep : xStep_callback; xFinal : xFinal_callback; xDestroy : 
  xDestroy_callback) : Integer; cdecl; external sqlite3_lib;
function sqlite3_create_window_function(db : psqlite3; const zFunctionName :
  PChar; nArg : Integer; eTextRep : Integer; pApp : Pointer; xStep :
  xStep_callback; xFinal : xFinal_callback; xValue : xValue_callback; xInverse :
  xInverse_callback; xDestroy : xDestroy_callback) : Integer; cdecl;
  external sqlite3_lib;

{ sqlite3_value_blob	          →	BLOB value
  sqlite3_value_double	        →	REAL value
  sqlite3_value_int	            →	32-bit INTEGER value
  sqlite3_value_int64	          →	64-bit INTEGER value
  sqlite3_value_pointer	        →	Pointer value
  sqlite3_value_text	          →	UTF-8 TEXT value
  sqlite3_value_text16	        →	UTF-16 TEXT value in the native byteorder
  sqlite3_value_text16be	      →	UTF-16be TEXT value
  sqlite3_value_text16le	      →	UTF-16le TEXT value
      
  sqlite3_value_bytes	          →	Size of a BLOB or a UTF-8 TEXT in bytes
  sqlite3_value_bytes16   	    → Size of UTF-16 TEXT in bytes
  sqlite3_value_type  	        →	Default datatype of the value
  sqlite3_value_numeric_type   	→ Best numeric datatype of the value
  sqlite3_value_nochange   	    → True if the column is unchanged in an UPDATE 
                                  against a virtual table.
  sqlite3_value_frombind   	    → True if value originated from a bound 
                                  parameter 
                                  
  These routines extract type, size, and content information from protected 
  sqlite3_value objects. Protected sqlite3_value objects are used to pass 
  parameter information into the functions that implement application-defined 
  SQL functions and virtual tables.

  These routines work only with protected sqlite3_value objects. Any attempt to 
  use these routines on an unprotected sqlite3_value is not threadsafe.

  These routines work just like the corresponding column access functions except 
  that these routines take a single protected sqlite3_value object pointer 
  instead of a sqlite3_stmt* pointer and an integer column number.

  The sqlite3_value_text16() interface extracts a UTF-16 string in the native 
  byte-order of the host machine. The sqlite3_value_text16be() and 
  sqlite3_value_text16le() interfaces extract UTF-16 strings as big-endian and 
  little-endian respectively.

  If sqlite3_value object V was initialized using 
  sqlite3_bind_pointer(S,I,P,X,D) or sqlite3_result_pointer(C,P,X,D) and if X 
  and Y are strings that compare equal according to strcmp(X,Y), then 
  sqlite3_value_pointer(V,Y) will return the pointer P. Otherwise, 
  sqlite3_value_pointer(V,Y) returns a NULL. The sqlite3_bind_pointer() routine 
  is part of the pointer passing interface added for SQLite 3.20.0.

  The sqlite3_value_type(V) interface returns the datatype code for the initial 
  datatype of the sqlite3_value object V. The returned value is one of 
  SQLITE_INTEGER, SQLITE_FLOAT, SQLITE_TEXT, SQLITE_BLOB, or SQLITE_NULL. Other 
  interfaces might change the datatype for an sqlite3_value object. For example, 
  if the datatype is initially SQLITE_INTEGER and sqlite3_value_text(V) is 
  called to extract a text value for that integer, then subsequent calls to 
  sqlite3_value_type(V) might return SQLITE_TEXT. Whether or not a persistent 
  internal datatype conversion occurs is undefined and may change from one 
  release of SQLite to the next.

  The sqlite3_value_numeric_type() interface attempts to apply numeric affinity 
  to the value. This means that an attempt is made to convert the value to an 
  integer or floating point. If such a conversion is possible without loss of 
  information (in other words, if the value is a string that looks like a 
  number) then the conversion is performed. Otherwise no conversion occurs. The 
  datatype after conversion is returned.

  Within the xUpdate method of a virtual table, the sqlite3_value_nochange(X) 
  interface returns true if and only if the column corresponding to X is 
  unchanged by the UPDATE operation that the xUpdate method call was invoked to 
  implement and if and the prior xColumn method call that was invoked to 
  extracted the value for that column returned without setting a result 
  (probably because it queried sqlite3_vtab_nochange() and found that the column 
  was unchanging). Within an xUpdate method, any value for which 
  sqlite3_value_nochange(X) is true will in all other respects appear to be a 
  NULL value. If sqlite3_value_nochange(X) is invoked anywhere other than within 
  an xUpdate method call for an UPDATE statement, then the return value is 
  arbitrary and meaningless.

  The sqlite3_value_frombind(X) interface returns non-zero if the value X 
  originated from one of the sqlite3_bind() interfaces. If X comes from an SQL 
  literal value, or a table column, or an expression, then 
  sqlite3_value_frombind(X) returns zero.

  Please pay particular attention to the fact that the pointer returned from 
  sqlite3_value_blob(), sqlite3_value_text(), or sqlite3_value_text16() can be 
  invalidated by a subsequent call to sqlite3_value_bytes(), 
  sqlite3_value_bytes16(), sqlite3_value_text(), or sqlite3_value_text16().

  These routines must be called from the same thread as the SQL function that 
  supplied the sqlite3_value* parameters.

  As long as the input parameter is correct, these routines can only fail if an 
  out-of-memory error occurs during a format conversion. Only the following 
  subset of interfaces are subject to out-of-memory errors:

    sqlite3_value_blob()
    sqlite3_value_text()
    sqlite3_value_text16()
    sqlite3_value_text16le()
    sqlite3_value_text16be()
    sqlite3_value_bytes()
    sqlite3_value_bytes16() 

  If an out-of-memory error occurs, then the return value from these routines is 
  the same as if the column had contained an SQL NULL value. Valid SQL NULL 
  returns can be distinguished from out-of-memory errors by invoking the 
  sqlite3_errcode() immediately after the suspect return value is obtained and 
  before any other SQLite interface is called on the same database connection. }
function sqlite3_value_blob(pVal : psqlite3_value) : Pointer; cdecl;
  external sqlite3_lib;
function sqlite3_value_double(pVal : psqlite3_value) : Double; cdecl;
  external sqlite3_lib;
function sqlite3_value_int(pVal : psqlite3_value) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_value_int64(pVal : psqlite3_value) : sqlite3_int64; cdecl;
  external sqlite3_lib;
function sqlite3_value_pointer(pVal : psqlite3_value; const zPType : PChar) :
  Pointer; cdecl; external sqlite3_lib;
function sqlite3_value_text(pVal : psqlite3_value) : PByte; cdecl;
  external sqlite3_lib;
function sqlite3_value_text16(pVal : psqlite3_value) : Pointer; cdecl;
  external sqlite3_lib;
function sqlite3_value_text16le(pVal : psqlite3_value) : Pointer; cdecl;
  external sqlite3_lib;
function sqlite3_value_text16be(pVal : psqlite3_value) : Pointer; cdecl;
  external sqlite3_lib;
function sqlite3_value_bytes(pVal : psqlite3_value) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_value_bytes16(pVal : psqlite3_value) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_value_type(pVal : psqlite3_value) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_value_numeric_type(pVal : psqlite3_value) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_value_nochange(pVal : psqlite3_value) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_value_frombind(pVal : psqlite3_value) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_value_subtype(V) function returns the subtype for an 
  application-defined SQL function argument V. The subtype information can be 
  used to pass a limited amount of context from one SQL function to another. Use 
  the sqlite3_result_subtype() routine to set the subtype for the return value 
  of an SQL function. }
function sqlite3_value_subtype(pVal : psqlite3_value) : Cardinal; cdecl;
  external sqlite3_lib;

{ The sqlite3_value_dup(V) interface makes a copy of the sqlite3_value object D 
  and returns a pointer to that copy. The sqlite3_value returned is a protected 
  sqlite3_value object even if the input is not. The sqlite3_value_dup(V) 
  interface returns NULL if V is NULL or if a memory allocation fails.

  The sqlite3_value_free(V) interface frees an sqlite3_value object previously 
  obtained from sqlite3_value_dup(). If V is a NULL pointer then 
  sqlite3_value_free(V) is a harmless no-op. }
function sqlite3_value_dup(const pOrig : psqlite3_value) : psqlite3_value; 
  cdecl; external sqlite3_lib;
procedure sqlite3_value_free(pOld : psqlite3_value); cdecl; 
  external sqlite3_lib;

{ Implementations of aggregate SQL functions use this routine to allocate memory 
  for storing their state.

  The first time the sqlite3_aggregate_context(C,N) routine is called for a 
  particular aggregate function, SQLite allocates N bytes of memory, zeroes out 
  that memory, and returns a pointer to the new memory. On second and subsequent 
  calls to sqlite3_aggregate_context() for the same aggregate function instance, 
  the same buffer is returned. Sqlite3_aggregate_context() is normally called 
  once for each invocation of the xStep callback and then one last time when the 
  xFinal callback is invoked. When no rows match an aggregate query, the xStep() 
  callback of the aggregate function implementation is never called and xFinal() 
  is called exactly once. In those cases, sqlite3_aggregate_context() might be 
  called for the first time from within xFinal().

  The sqlite3_aggregate_context(C,N) routine returns a NULL pointer when first 
  called if N is less than or equal to zero or if a memory allocate error 
  occurs.

  The amount of space allocated by sqlite3_aggregate_context(C,N) is determined 
  by the N parameter on first successful call. Changing the value of N in any 
  subsequent call to sqlite3_aggregate_context() within the same aggregate 
  function instance will not resize the memory allocation. Within the xFinal 
  callback, it is customary to set N=0 in calls to 
  sqlite3_aggregate_context(C,N) so that no pointless memory allocations occur.

  SQLite automatically frees the memory allocated by sqlite3_aggregate_context() 
  when the aggregate query concludes.

  The first parameter must be a copy of the SQL function context that is the 
  first parameter to the xStep or xFinal callback routine that implements the 
  aggregate function.

  This routine must be called from the same thread in which the aggregate SQL 
  function is running. }
function sqlite3_aggregate_context(context : psqlite3_context; nBytes : Integer)
  : Pointer; cdecl; external sqlite3_lib;

{ The sqlite3_user_data() interface returns a copy of the pointer that was the 
  pUserData parameter (the 5th parameter) of the sqlite3_create_function() and 
  sqlite3_create_function16() routines that originally registered the 
  application defined function.

  This routine must be called from the same thread in which the 
  application-defined function is running. }
function sqlite3_user_data(context : psqlite3_context) : Pointer; cdecl;
  external sqlite3_lib;

{ The sqlite3_context_db_handle() interface returns a copy of the pointer to the 
  database connection (the 1st parameter) of the sqlite3_create_function() and 
  sqlite3_create_function16() routines that originally registered the 
  application defined function. }
function sqlite3_context_db_handle(context : psqlite3_context) : psqlite3;
  cdecl; external sqlite3_lib;

{ These functions may be used by (non-aggregate) SQL functions to associate 
  metadata with argument values. If the same value is passed to multiple 
  invocations of the same SQL function during query execution, under some 
  circumstances the associated metadata may be preserved. An example of where 
  this might be useful is in a regular-expression matching function. The 
  compiled version of the regular expression can be stored as metadata 
  associated with the pattern string. Then as long as the pattern string remains 
  the same, the compiled regular expression can be reused on multiple 
  invocations of the same function.

  The sqlite3_get_auxdata(C,N) interface returns a pointer to the metadata 
  associated by the sqlite3_set_auxdata(C,N,P,X) function with the Nth argument 
  value to the application-defined function. N is zero for the left-most 
  function argument. If there is no metadata associated with the function 
  argument, the sqlite3_get_auxdata(C,N) interface returns a NULL pointer.

  The sqlite3_set_auxdata(C,N,P,X) interface saves P as metadata for the N-th 
  argument of the application-defined function. Subsequent calls to 
  sqlite3_get_auxdata(C,N) return P from the most recent 
  sqlite3_set_auxdata(C,N,P,X) call if the metadata is still valid or NULL if 
  the metadata has been discarded. After each call to 
  sqlite3_set_auxdata(C,N,P,X) where X is not NULL, SQLite will invoke the 
  destructor function X with parameter P exactly once, when the metadata is 
  discarded. SQLite is free to discard the metadata at any time, including:

    when the corresponding function parameter changes, or
    when sqlite3_reset() or sqlite3_finalize() is called for the SQL statement, 
      or
    when sqlite3_set_auxdata() is invoked again on the same parameter, or
    during the original sqlite3_set_auxdata() call when a memory allocation 
      error occurs. 

  Note the last bullet in particular. The destructor X in 
  sqlite3_set_auxdata(C,N,P,X) might be called immediately, before the 
  sqlite3_set_auxdata() interface even returns. Hence sqlite3_set_auxdata() 
  should be called near the end of the function implementation and the function 
  implementation should not make any use of P after sqlite3_set_auxdata() has 
  been called.

  In practice, metadata is preserved between function calls for function 
  parameters that are compile-time constants, including literal values and 
  parameters and expressions composed from the same.

  The value of the N parameter to these interfaces should be non-negative. 
  Future enhancements may make use of negative N values to define new kinds of 
  function caching behavior.

  These routines must be called from the same thread in which the SQL function 
  is running. }
function sqlite3_get_auxdata(pCtx : psqlite3_context; N : Integer) : Pointer;
  cdecl; external sqlite3_lib;
procedure sqlite3_set_auxdata(pCtx : psqlite3_context; N : Integer; pAux :
  Pointer; xDelete : xDelete_callback); cdecl; external sqlite3_lib;

{ These routines are used by the xFunc or xFinal callbacks that implement SQL 
  functions and aggregates. See sqlite3_create_function() and 
  sqlite3_create_function16() for additional information.

  These functions work very much like the parameter binding family of functions 
  used to bind values to host parameters in prepared statements. Refer to the 
  SQL parameter documentation for additional information.

  The sqlite3_result_blob() interface sets the result from an 
  application-defined function to be the BLOB whose content is pointed to by the 
  second parameter and which is N bytes long where N is the third parameter.

  The sqlite3_result_zeroblob(C,N) and sqlite3_result_zeroblob64(C,N) interfaces 
  set the result of the application-defined function to be a BLOB containing all
  zero bytes and N bytes in size.

  The sqlite3_result_double() interface sets the result from an 
  application-defined function to be a floating point value specified by its 2nd 
  argument.

  The sqlite3_result_error() and sqlite3_result_error16() functions cause the 
  implemented SQL function to throw an exception. SQLite uses the string pointed 
  to by the 2nd parameter of sqlite3_result_error() or sqlite3_result_error16() 
  as the text of an error message. SQLite interprets the error message string 
  from sqlite3_result_error() as UTF-8. SQLite interprets the string from 
  sqlite3_result_error16() as UTF-16 using the same byte-order determination 
  rules as sqlite3_bind_text16(). If the third parameter to 
  sqlite3_result_error() or sqlite3_result_error16() is negative then SQLite 
  takes as the error message all text up through the first zero character. If 
  the third parameter to sqlite3_result_error() or sqlite3_result_error16() is 
  non-negative then SQLite takes that many bytes (not characters) from the 2nd 
  parameter as the error message. The sqlite3_result_error() and 
  sqlite3_result_error16() routines make a private copy of the error message 
  text before they return. Hence, the calling function can deallocate or modify 
  the text after they return without harm. The sqlite3_result_error_code() 
  function changes the error code returned by SQLite as a result of an error in 
  a function. By default, the error code is SQLITE_ERROR. A subsequent call to 
  sqlite3_result_error() or sqlite3_result_error16() resets the error code to 
  SQLITE_ERROR.

  The sqlite3_result_error_toobig() interface causes SQLite to throw an error 
  indicating that a string or BLOB is too long to represent.

  The sqlite3_result_error_nomem() interface causes SQLite to throw an error 
  indicating that a memory allocation failed.

  The sqlite3_result_int() interface sets the return value of the 
  application-defined function to be the 32-bit signed integer value given in 
  the 2nd argument. The sqlite3_result_int64() interface sets the return value 
  of the application-defined function to be the 64-bit signed integer value 
  given in the 2nd argument.

  The sqlite3_result_null() interface sets the return value of the 
  application-defined function to be NULL.

  The sqlite3_result_text(), sqlite3_result_text16(), sqlite3_result_text16le(), 
  and sqlite3_result_text16be() interfaces set the return value of the 
  application-defined function to be a text string which is represented as 
  UTF-8, UTF-16 native byte order, UTF-16 little endian, or UTF-16 big endian, 
  respectively. The sqlite3_result_text64() interface sets the return value of 
  an application-defined function to be a text string in an encoding specified 
  by the fifth (and last) parameter, which must be one of SQLITE_UTF8, 
  SQLITE_UTF16, SQLITE_UTF16BE, or SQLITE_UTF16LE. SQLite takes the text result 
  from the application from the 2nd parameter of the sqlite3_result_text* 
  interfaces. If the 3rd parameter to the sqlite3_result_text* interfaces is 
  negative, then SQLite takes result text from the 2nd parameter through the 
  first zero character. If the 3rd parameter to the sqlite3_result_text* 
  interfaces is non-negative, then as many bytes (not characters) of the text 
  pointed to by the 2nd parameter are taken as the application-defined function 
  result. If the 3rd parameter is non-negative, then it must be the byte offset 
  into the string where the NUL terminator would appear if the string where NUL 
  terminated. If any NUL characters occur in the string at a byte offset that is 
  less than the value of the 3rd parameter, then the resulting string will 
  contain embedded NULs and the result of expressions operating on strings with 
  embedded NULs is undefined. If the 4th parameter to the sqlite3_result_text* 
  interfaces or sqlite3_result_blob is a non-NULL pointer, then SQLite calls 
  that function as the destructor on the text or BLOB result when it has 
  finished using that result. If the 4th parameter to the sqlite3_result_text* 
  interfaces or to sqlite3_result_blob is the special constant SQLITE_STATIC, 
  then SQLite assumes that the text or BLOB result is in constant space and does 
  not copy the content of the parameter nor call a destructor on the content 
  when it has finished using that result. If the 4th parameter to the 
  sqlite3_result_text* interfaces or sqlite3_result_blob is the special constant 
  SQLITE_TRANSIENT then SQLite makes a copy of the result into space obtained 
  from sqlite3_malloc() before it returns.

  For the sqlite3_result_text16(), sqlite3_result_text16le(), and 
  sqlite3_result_text16be() routines, and for sqlite3_result_text64() when the 
  encoding is not UTF8, if the input UTF16 begins with a byte-order mark (BOM, 
  U+FEFF) then the BOM is removed from the string and the rest of the string is 
  interpreted according to the byte-order specified by the BOM. The byte-order 
  specified by the BOM at the beginning of the text overrides the byte-order 
  specified by the interface procedure. So, for example, if 
  sqlite3_result_text16le() is invoked with text that begins with bytes 0xfe, 
  0xff (a big-endian byte-order mark) then the first two bytes of input are 
  skipped and the remaining input is interpreted as UTF16BE text.

  For UTF16 input text to the sqlite3_result_text16(), 
  sqlite3_result_text16be(), sqlite3_result_text16le(), and 
  sqlite3_result_text64() routines, if the text contains invalid UTF16 
  characters, the invalid characters might be converted into the unicode 
  replacement character, U+FFFD.

  The sqlite3_result_value() interface sets the result of the 
  application-defined function to be a copy of the unprotected sqlite3_value 
  object specified by the 2nd parameter. The sqlite3_result_value() interface 
  makes a copy of the sqlite3_value so that the sqlite3_value specified in the 
  parameter may change or be deallocated after sqlite3_result_value() returns 
  without harm. A protected sqlite3_value object may always be used where an 
  unprotected sqlite3_value object is required, so either kind of sqlite3_value 
  object can be used with this interface.

  The sqlite3_result_pointer(C,P,T,D) interface sets the result to an SQL NULL 
  value, just like sqlite3_result_null(C), except that it also associates the 
  host-language pointer P or type T with that NULL value such that the pointer 
  can be retrieved within an application-defined SQL function using 
  sqlite3_value_pointer(). If the D parameter is not NULL, then it is a pointer 
  to a destructor for the P parameter. SQLite invokes D with P as its only 
  argument when SQLite is finished with P. The T parameter should be a static 
  string and preferably a string literal. The sqlite3_result_pointer() routine 
  is part of the pointer passing interface added for SQLite 3.20.0.

  If these routines are called from within the different thread than the one 
  containing the application-defined function that received the sqlite3_context 
  pointer, the results are undefined. }
procedure sqlite3_result_blob(pCtx : psqlite3_context; const z : Pointer;
  n : Integer; xDel : xDel_calback); cdecl; external sqlite3_lib;
procedure sqlite3_result_blob64(pCtx : psqlite3_context; const z : Pointer;
  n : sqlite3_uint64; xDel : xDel_calback); cdecl; external sqlite3_lib;
procedure sqlite3_result_double(pCtx : psqlite3_context; rVal : Double); cdecl;
  external sqlite3_lib;
procedure sqlite3_result_error(pCtx : psqlite3_context; const z : PChar; n :
  Integer); cdecl; external sqlite3_lib;
procedure sqlite3_result_error16(pCtx : psqlite3_context; const z : Pointer;
  n : Integer); cdecl; external sqlite3_lib;
procedure sqlite3_result_error_toobig(pCtx : psqlite3_context); cdecl;
  external sqlite3_lib;
procedure sqlite3_result_error_nomem(pCtx : psqlite3_context); cdecl;
  external sqlite3_lib;
procedure sqlite3_result_error_code(pCtx : psqlite3_context; errCode : Integer);
  cdecl; external sqlite3_lib;
procedure sqlite3_result_int(pCtx : psqlite3_context; iVal : Integer); cdecl;
  external sqlite3_lib;
procedure sqlite3_result_int64(pCtx : psqlite3_context; iVal : sqlite3_int64);
  cdecl; external sqlite3_lib;
procedure sqlite3_result_null(pCtx : psqlite3_context); cdecl; 
  external sqlite3_lib;
procedure sqlite3_result_text(pCtx : psqlite3_context; const z : PChar; n :
  Integer; xDel : xDel_calback); cdecl; external sqlite3_lib;
procedure sqlite3_result_text64(pCtx : psqlite3_context; const z : PChar;
  n : sqlite3_uint64; xDel : xDel_calback; enc : Byte); cdecl;
  external sqlite3_lib;
procedure sqlite3_result_text16(pCtx : psqlite3_context; const z : Pointer;
  n : Integer; xDel : xDel_calback); cdecl; external sqlite3_lib;
procedure sqlite3_result_text16le(pCtx : psqlite3_context; const z : Pointer;
  n : Integer; xDel : xDel_calback); cdecl; external sqlite3_lib;
procedure sqlite3_result_text16be(pCtx : psqlite3_context; const z : Pointer;
  n : Integer; xDel : xDel_calback); cdecl; external sqlite3_lib;
procedure sqlite3_result_value(pCtx : psqlite3_context; pValue : 
  psqlite3_value); cdecl; external sqlite3_lib;
procedure sqlite3_result_pointer(pCtx : psqlite3_context;  pPtr : Pointer;
  const zPType : PChar; xDestructor : xDestructor_callback); cdecl;
  external sqlite3_lib;
procedure sqlite3_result_zeroblob(pCtx : psqlite3_context; n : Integer); cdecl;
  external sqlite3_lib;
function sqlite3_result_zeroblob64(pCtx : psqlite3_context; n : sqlite3_uint64)
  : Integer; cdecl; external sqlite3_lib;

{ The sqlite3_result_subtype(C,T) function causes the subtype of the result from 
  the application-defined SQL function with sqlite3_context C to be the value T. 
  Only the lower 8 bits of the subtype T are preserved in current versions of 
  SQLite; higher order bits are discarded. The number of subtype bytes preserved 
  by SQLite might increase in future releases of SQLite. }
procedure sqlite3_result_subtype(pCtx : psqlite3_context; eSubtype : Cardinal);
  cdecl; external sqlite3_lib;

{ These functions add, remove, or modify a collation associated with the 
  database connection specified as the first argument.

  The name of the collation is a UTF-8 string for sqlite3_create_collation() and 
  sqlite3_create_collation_v2() and a UTF-16 string in native byte order for 
  sqlite3_create_collation16(). Collation names that compare equal according to 
  sqlite3_strnicmp() are considered to be the same name.

  The third argument (eTextRep) must be one of the constants:

    SQLITE_UTF8,
    SQLITE_UTF16LE,
    SQLITE_UTF16BE,
    SQLITE_UTF16, or
    SQLITE_UTF16_ALIGNED. 

  The eTextRep argument determines the encoding of strings passed to the 
  collating function callback, xCompare. The SQLITE_UTF16 and 
  SQLITE_UTF16_ALIGNED values for eTextRep force strings to be UTF16 with native 
  byte order. The SQLITE_UTF16_ALIGNED value for eTextRep forces strings to 
  begin on an even byte address.

  The fourth argument, pArg, is an application data pointer that is passed 
  through as the first argument to the collating function callback.

  The fifth argument, xCompare, is a pointer to the collating function. Multiple 
  collating functions can be registered using the same name but with different 
  eTextRep parameters and SQLite will use whichever function requires the least 
  amount of data transformation. If the xCompare argument is NULL then the 
  collating function is deleted. When all collating functions having the same 
  name are deleted, that collation is no longer usable.

  The collating function callback is invoked with a copy of the pArg application 
  data pointer and with two strings in the encoding specified by the eTextRep 
  argument. The two integer parameters to the collating function callback are 
  the length of the two strings, in bytes. The collating function must return an 
  integer that is negative, zero, or positive if the first string is less than, 
  equal to, or greater than the second, respectively. A collating function must 
  always return the same answer given the same inputs. If two or more collating 
  functions are registered to the same collation name (using different eTextRep 
  values) then all must give an equivalent answer when invoked with equivalent 
  strings. The collating function must obey the following properties for all 
  strings A, B, and C:

    If A==B then B==A.
    If A==B and B==C then A==C.
    If A<B THEN B>A.
    If A<B and B<C then A<C. 

  If a collating function fails any of the above constraints and that collating 
  function is registered and used, then the behavior of SQLite is undefined.

  The sqlite3_create_collation_v2() works like sqlite3_create_collation() with 
  the addition that the xDestroy callback is invoked on pArg when the collating 
  function is deleted. Collating functions are deleted when they are overridden 
  by later calls to the collation creation functions or when the database 
  connection is closed using sqlite3_close().

  The xDestroy callback is not called if the sqlite3_create_collation_v2() 
  function fails. Applications that invoke sqlite3_create_collation_v2() with a 
  non-NULL xDestroy argument should check the return code and dispose of the 
  application data pointer themselves rather than expecting SQLite to deal with 
  it for them. This is different from every other SQLite interface. The 
  inconsistency is unfortunate but cannot be changed without breaking backwards 
  compatibility. }
function sqlite3_create_collation(db : psqlite3; const zName : PChar; eTextRep :
  Integer; pArg : Pointer; xCompare : xCompare_callback) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_create_collation_v2(db : psqlite3; const zName : PChar;
  eTextRep : Integer; pArg : Pointer; xCompare : xCompare_callback; xDestroy :
  xDestroy_callback) : Integer; cdecl; external sqlite3_lib;
function sqlite3_create_collation16(db : psqlite3; const zName : Pointer;
  eTextRep : Integer; pArg : Pointer; xCompare : xCompare_callback) : Integer;
  cdecl; external sqlite3_lib;

{ To avoid having to register all collation sequences before a database can be 
  used, a single callback function may be registered with the database 
  connection to be invoked whenever an undefined collation sequence is required.

  If the function is registered using the sqlite3_collation_needed() API, then 
  it is passed the names of undefined collation sequences as strings encoded in 
  UTF-8. If sqlite3_collation_needed16() is used, the names are passed as UTF-16 
  in machine native byte order. A call to either function replaces the existing 
  collation-needed callback.

  When the callback is invoked, the first argument passed is a copy of the 
  second argument to sqlite3_collation_needed() or sqlite3_collation_needed16(). 
  The second argument is the database connection. The third argument is one of 
  SQLITE_UTF8, SQLITE_UTF16BE, or SQLITE_UTF16LE, indicating the most desirable 
  form of the collation sequence function required. The fourth parameter is the 
  name of the required collation sequence.

  The callback function should register the desired collation using 
  sqlite3_create_collation(), sqlite3_create_collation16(), or 
  sqlite3_create_collation_v2(). }
function sqlite3_collation_needed(db : psqlite3; pCollNeededArg : Pointer;
  xColNeeded : xCollNeeded_callback) : Integer; cdecl; external sqlite3_lib;
function sqlite3_collation_needed16(db : psqlite3; pColNeededArg : Pointer;
  xCollNeeded16 : xCollNeeded16_callback) : Integer; cdecl; 
  external sqlite3_lib;

{ Specify the activation key for a CEROD database. Unless activated, none of the 
  CEROD routines will work. }
procedure sqlite3_activate_cerod(const zPassPhrase : PChar); cdecl;
  external sqlite3_lib;

{ The sqlite3_sleep() function causes the current thread to suspend execution 
  for at least a number of milliseconds specified in its parameter.

  If the operating system does not support sleep requests with millisecond time 
  resolution, then the time will be rounded up to the nearest second. The number 
  of milliseconds of sleep actually requested from the operating system is 
  returned.

  SQLite implements this interface by calling the xSleep() method of the default 
  sqlite3_vfs object. If the xSleep() method of the default VFS is not 
  implemented correctly, or not implemented at all, then the behavior of 
  sqlite3_sleep() may deviate from the description in the previous paragraphs. }
function sqlite3_sleep(ms : Integer) : Integer; cdecl; external sqlite3_lib;

{ These interfaces are available only on Windows. The 
  sqlite3_win32_set_directory interface is used to set the value associated with 
  the sqlite3_temp_directory or sqlite3_data_directory variable, to zValue, 
  depending on the value of the type parameter. The zValue parameter should be 
  NULL to cause the previous value to be freed via sqlite3_free; a non-NULL 
  value will be copied into memory obtained from sqlite3_malloc prior to being 
  used. The sqlite3_win32_set_directory interface returns SQLITE_OK to indicate 
  success, SQLITE_ERROR if the type is unsupported, or SQLITE_NOMEM if memory 
  could not be allocated. The value of the sqlite3_data_directory variable is 
  intended to act as a replacement for the current directory on the 
  sub-platforms of Win32 where that concept is not present, e.g. WinRT and UWP. 
  The sqlite3_win32_set_directory8 and sqlite3_win32_set_directory16 interfaces 
  behave exactly the same as the sqlite3_win32_set_directory interface except 
  the string parameter must be UTF-8 or UTF-16, respectively. }
function sqlite3_win32_set_directory(type_ : LongWord; zValue : Pointer) :
  Integer; cdecl; external sqlite3_lib;
function sqlite3_win32_set_directory8(type_ : LongWord; const zValue : PChar) :
  Integer; cdecl; external sqlite3_lib;
function sqlite3_win32_set_directory16(type_ : LongWord; const zValue : Pointer)
  : Integer; cdecl; external sqlite3_lib;

{ The sqlite3_get_autocommit() interface returns non-zero or zero if the given 
  database connection is or is not in autocommit mode, respectively. Autocommit 
  mode is on by default. Autocommit mode is disabled by a BEGIN statement. 
  Autocommit mode is re-enabled by a COMMIT or ROLLBACK.

  If certain kinds of errors occur on a statement within a multi-statement 
  transaction (errors including SQLITE_FULL, SQLITE_IOERR, SQLITE_NOMEM, 
  SQLITE_BUSY, and SQLITE_INTERRUPT) then the transaction might be rolled back 
  automatically. The only way to find out whether SQLite automatically rolled 
  back the transaction after an error is to use this function.

  If another thread changes the autocommit status of the database connection 
  while this routine is running, then the return value is undefined. }
function sqlite3_get_autocommit(db : psqlite3) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_db_handle interface returns the database connection handle to 
  which a prepared statement belongs. The database connection returned by 
  sqlite3_db_handle is the same database connection that was the first argument 
  to the sqlite3_prepare_v2() call (or its variants) that was used to create the 
  statement in the first place. }
function sqlite3_db_handle(pStmt : psqlite3_stmt) : psqlite3; cdecl;
  external sqlite3_lib;

{ The sqlite3_db_filename(D,N) interface returns a pointer to the filename 
  associated with database N of connection D. If there is no attached database N 
  on the database connection D, or if database N is a temporary or in-memory 
  database, then this function will return either a NULL pointer or an empty 
  string.

  The string value returned by this routine is owned and managed by the database 
  connection. The value will be valid until the database N is DETACH-ed or until 
  the database connection closes.

  The filename returned by this function is the output of the xFullPathname 
  method of the VFS. In other words, the filename will be an absolute pathname, 
  even if the filename used to open the database originally was a URI or 
  relative pathname.

  If the filename pointer returned by this routine is not NULL, then it can be 
  used as the filename input parameter to these routines:

    sqlite3_uri_parameter()
    sqlite3_uri_boolean()
    sqlite3_uri_int64()
    sqlite3_filename_database()
    sqlite3_filename_journal()
    sqlite3_filename_wal() }
function sqlite3_db_filename(db : psqlite3; const zDbName : PChar) : PChar;
  external sqlite3_lib;

{ The sqlite3_db_readonly(D,N) interface returns 1 if the database N of 
  connection D is read-only, 0 if it is read/write, or -1 if N is not the name 
  of a database on connection D. }
function sqlite3_db_readonly(db : psqlite3; const zDbName : PChar) : Integer;
  cdecl; external sqlite3_lib;

{ This interface returns a pointer to the next prepared statement after pStmt 
  associated with the database connection pDb. If pStmt is NULL then this 
  interface returns a pointer to the first prepared statement associated with 
  the database connection pDb. If no prepared statement satisfies the conditions 
  of this routine, it returns NULL.

  The database connection pointer D in a call to sqlite3_next_stmt(D,S) must 
  refer to an open database connection and in particular must not be a NULL 
  pointer. }
function sqlite3_next_stmt(pDb : psqlite3; pStmt : psqlite3_stmt) : 
  psqlite3_stmt; cdecl; external sqlite3_lib;

{ The sqlite3_commit_hook() interface registers a callback function to be 
  invoked whenever a transaction is committed. Any callback set by a previous 
  call to sqlite3_commit_hook() for the same database connection is overridden. 
  The sqlite3_rollback_hook() interface registers a callback function to be 
  invoked whenever a transaction is rolled back. Any callback set by a previous 
  call to sqlite3_rollback_hook() for the same database connection is 
  overridden. The pArg argument is passed through to the callback. If the 
  callback on a commit hook function returns non-zero, then the commit is 
  converted into a rollback.

  The sqlite3_commit_hook(D,C,P) and sqlite3_rollback_hook(D,C,P) functions 
  return the P argument from the previous call of the same function on the same 
  database connection D, or NULL for the first call for each function on D.

  The commit and rollback hook callbacks are not reentrant. The callback 
  implementation must not do anything that will modify the database connection 
  that invoked the callback. Any actions to modify the database connection must 
  be deferred until after the completion of the sqlite3_step() call that 
  triggered the commit or rollback hook in the first place. Note that running 
  any other SQL statements, including SELECT statements, or merely calling 
  sqlite3_prepare_v2() and sqlite3_step() will modify the database connections 
  for the meaning of "modify" in this paragraph.

  Registering a NULL function disables the callback.

  When the commit hook callback routine returns zero, the COMMIT operation is 
  allowed to continue normally. If the commit hook returns non-zero, then the 
  COMMIT is converted into a ROLLBACK. The rollback hook is invoked on a 
  rollback that results from a commit hook returning non-zero, just as it would 
  be with any other rollback.

  For the purposes of this API, a transaction is said to have been rolled back 
  if an explicit "ROLLBACK" statement is executed, or an error or constraint 
  causes an implicit rollback to occur. The rollback callback is not invoked if 
  a transaction is automatically rolled back because the database connection is 
  closed. }
function sqlite3_commit_hook(db : psqlite3; xCallback : xCallback_callback; 
  pArg : Pointer) : Pointer; cdecl; external sqlite3_lib;
function sqlite3_rollback_hook(db : psqlite3; xCallback : xCallback_callback;
  pArg : Pointer) : Pointer; cdecl; external sqlite3_lib;

{ The sqlite3_update_hook() interface registers a callback function with the 
  database connection identified by the first argument to be invoked whenever a 
  row is updated, inserted or deleted in a rowid table. Any callback set by a 
  previous call to this function for the same database connection is overridden.

  The second argument is a pointer to the function to invoke when a row is 
  updated, inserted or deleted in a rowid table. The first argument to the 
  callback is a copy of the third argument to sqlite3_update_hook(). The second 
  callback argument is one of SQLITE_INSERT, SQLITE_DELETE, or SQLITE_UPDATE, 
  depending on the operation that caused the callback to be invoked. The third 
  and fourth arguments to the callback contain pointers to the database and 
  table name containing the affected row. The final callback parameter is the 
  rowid of the row. In the case of an update, this is the rowid after the update 
  takes place.

  The update hook is not invoked when internal system tables are modified (i.e. 
  sqlite_sequence). The update hook is not invoked when WITHOUT ROWID tables are 
  modified.

  In the current implementation, the update hook is not invoked when conflicting 
  rows are deleted because of an ON CONFLICT REPLACE clause. Nor is the update 
  hook invoked when rows are deleted using the truncate optimization. The 
  exceptions defined in this paragraph might change in a future release of 
  SQLite.

  The update hook implementation must not do anything that will modify the 
  database connection that invoked the update hook. Any actions to modify the 
  database connection must be deferred until after the completion of the 
  sqlite3_step() call that triggered the update hook. Note that 
  sqlite3_prepare_v2() and sqlite3_step() both modify their database connections 
  for the meaning of "modify" in this paragraph.

  The sqlite3_update_hook(D,C,P) function returns the P argument from the 
  previous call on the same database connection D, or NULL for the first call on 
  D. }
function sqlite3_update_hook(db : psqlite3; xCallback : 
  xCallbackUpdateHook_callback; pArg : Pointer) : Pointer; cdecl;
  external sqlite3_lib;

{ This routine enables or disables the sharing of the database cache and schema 
  data structures between connections to the same database. Sharing is enabled 
  if the argument is true and disabled if the argument is false.

  Cache sharing is enabled and disabled for an entire process. This is a change 
  as of SQLite version 3.5.0 (2007-09-04). In prior versions of SQLite, sharing 
  was enabled or disabled for each thread separately.

  The cache sharing mode set by this interface effects all subsequent calls to 
  sqlite3_open(), sqlite3_open_v2(), and sqlite3_open16(). Existing database 
  connections continue to use the sharing mode that was in effect at the time 
  they were opened.

  This routine returns SQLITE_OK if shared cache was enabled or disabled 
  successfully. An error code is returned otherwise.

  Shared cache is disabled by default. It is recommended that it stay that way. 
  In other words, do not use this routine. This interface continues to be 
  provided for historical compatibility, but its use is discouraged. Any use of 
  shared cache is discouraged. If shared cache must be used, it is recommended 
  that shared cache only be enabled for individual database connections using 
  the sqlite3_open_v2() interface with the SQLITE_OPEN_SHAREDCACHE flag.

  Note: This method is disabled on MacOS X 10.7 and iOS version 5.0 and will 
  always return SQLITE_MISUSE. On those systems, shared cache mode should be 
  enabled per-database connection via sqlite3_open_v2() with 
  SQLITE_OPEN_SHAREDCACHE.

  This interface is threadsafe on processors where writing a 32-bit integer is 
  atomic. }
function sqlite3_enable_shared_cache(enable : Integer) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_release_memory() interface attempts to free N bytes of heap memory 
  by deallocating non-essential memory allocations held by the database library. 
  Memory used to cache database pages to improve performance is an example of 
  non-essential memory. sqlite3_release_memory() returns the number of bytes 
  actually freed, which might be more or less than the amount requested. The 
  sqlite3_release_memory() routine is a no-op returning zero if SQLite is not 
  compiled with SQLITE_ENABLE_MEMORY_MANAGEMENT. }
function sqlite3_release_memory(n : Integer) : Integer; cdecl; 
  external sqlite3_lib;

{ The sqlite3_db_release_memory(D) interface attempts to free as much heap
  memory as possible from database connection D. Unlike the 
  sqlite3_release_memory() interface, this interface is in effect even when the 
  SQLITE_ENABLE_MEMORY_MANAGEMENT compile-time option is omitted. }
function sqlite3_db_release_memory(db : psqlite3) : Integer; cdecl;
  external sqlite3_lib;

{ These interfaces impose limits on the amount of heap memory that will be by 
  all database connections within a single process.

  The sqlite3_soft_heap_limit64() interface sets and/or queries the soft limit 
  on the amount of heap memory that may be allocated by SQLite. SQLite strives 
  to keep heap memory utilization below the soft heap limit by reducing the 
  number of pages held in the page cache as heap memory usages approaches the 
  limit. The soft heap limit is "soft" because even though SQLite strives to 
  stay below the limit, it will exceed the limit rather than generate an 
  SQLITE_NOMEM error. In other words, the soft heap limit is advisory only.

  The sqlite3_hard_heap_limit64(N) interface sets a hard upper bound of N bytes 
  on the amount of memory that will be allocated. The 
  sqlite3_hard_heap_limit64(N) interface is similar to 
  sqlite3_soft_heap_limit64(N) except that memory allocations will fail when the 
  hard heap limit is reached.

  The return value from both sqlite3_soft_heap_limit64() and 
  sqlite3_hard_heap_limit64() is the size of the heap limit prior to the call, 
  or negative in the case of an error. If the argument N is negative then no 
  change is made to the heap limit. Hence, the current size of heap limits can 
  be determined by invoking sqlite3_soft_heap_limit64(-1) or 
  sqlite3_hard_heap_limit(-1).

  Setting the heap limits to zero disables the heap limiter mechanism.

  The soft heap limit may not be greater than the hard heap limit. If the hard 
  heap limit is enabled and if sqlite3_soft_heap_limit(N) is invoked with a 
  value of N that is greater than the hard heap limit, the the soft heap limit 
  is set to the value of the hard heap limit. The soft heap limit is 
  automatically enabled whenever the hard heap limit is enabled. When 
  sqlite3_hard_heap_limit64(N) is invoked and the soft heap limit is outside the 
  range of 1..N, then the soft heap limit is set to N. Invoking 
  sqlite3_soft_heap_limit64(0) when the hard heap limit is enabled makes the 
  soft heap limit equal to the hard heap limit.

  The memory allocation limits can also be adjusted using PRAGMA soft_heap_limit 
  and PRAGMA hard_heap_limit.

  The heap limits are not enforced in the current implementation if one or more 
  of following conditions are true:

    The limit value is set to zero.
    Memory accounting is disabled using a combination of the 
      sqlite3_config(SQLITE_CONFIG_MEMSTATUS,...) start-time option and the 
      SQLITE_DEFAULT_MEMSTATUS compile-time option.
    An alternative page cache implementation is specified using 
      sqlite3_config(SQLITE_CONFIG_PCACHE2,...).
    The page cache allocates from its own memory pool supplied by 
      sqlite3_config(SQLITE_CONFIG_PAGECACHE,...) rather than from the heap. 

  The circumstances under which SQLite will enforce the heap limits may changes 
  in future releases of SQLite. }
function sqlite3_soft_heap_limit64(N : sqlite3_int64) : sqlite3_int64; cdecl;
  external sqlite3_lib;
function sqlite3_hard_heap_limit64(N : sqlite3_int64) : sqlite3_int64; cdecl;
  external sqlite3_lib;

{ The sqlite3_table_column_metadata(X,D,T,C,....) routine returns information 
  about column C of table T in database D on database connection X. The 
  sqlite3_table_column_metadata() interface returns SQLITE_OK and fills in the 
  non-NULL pointers in the final five arguments with appropriate values if the 
  specified column exists. The sqlite3_table_column_metadata() interface returns 
  SQLITE_ERROR if the specified column does not exist. If the column-name 
  parameter to sqlite3_table_column_metadata() is a NULL pointer, then this 
  routine simply checks for the existence of the table and returns SQLITE_OK if 
  the table exists and SQLITE_ERROR if it does not. If the table name parameter 
  T in a call to sqlite3_table_column_metadata(X,D,T,C,...) is NULL then the 
  result is undefined behavior.

  The column is identified by the second, third and fourth parameters to this 
  function. The second parameter is either the name of the database (i.e. 
  "main", "temp", or an attached database) containing the specified table or 
  NULL. If it is NULL, then all attached databases are searched for the table 
  using the same algorithm used by the database engine to resolve unqualified 
  table references.

  The third and fourth parameters to this function are the table and column name 
  of the desired column, respectively.

  Metadata is returned by writing to the memory locations passed as the 5th and 
  subsequent parameters to this function. 

  The memory pointed to by the character pointers returned for the declaration 
  type and collation sequence is valid until the next call to any SQLite API 
  function.

  If the specified table is actually a view, an error code is returned.

  If the specified column is "rowid", "oid" or "_rowid_" and the table is not a 
  WITHOUT ROWID table and an INTEGER PRIMARY KEY column has been explicitly 
  declared, then the output parameters are set for the explicitly declared 
  column.

  This function causes all database schemas to be read from disk and parsed, if 
  that has not already been done, and returns an error if any errors are 
  encountered while loading the schema. }
function sqlite3_table_column_metadata(db : psqlite3; const zDbName : PChar;
  const zTableName : PChar; const zColumnName : PChar; pzDataType : PPChar;
  pzCollSeq : PPChar; pNotNull : PInteger; pPrimaryKey : PInteger; pAutoinc :
  PInteger) : Integer; cdecl; external sqlite3_lib;

{ This interface loads an SQLite extension library from the named file.

  The sqlite3_load_extension() interface attempts to load an SQLite extension 
  library contained in the file zFile. If the file cannot be loaded directly, 
  attempts are made to load with various operating-system specific extensions 
  added. So for example, if "samplelib" cannot be loaded, then names like 
  "samplelib.so" or "samplelib.dylib" or "samplelib.dll" might be tried also.

  The entry point is zProc. zProc may be 0, in which case SQLite will try to 
  come up with an entry point name on its own. It first tries 
  "sqlite3_extension_init". If that does not work, it constructs a name 
  "sqlite3_X_init" where the X is consists of the lower-case equivalent of all 
  ASCII alphabetic characters in the filename from the last "/" to the first 
  following "." and omitting any initial "lib". The sqlite3_load_extension() 
  interface returns SQLITE_OK on success and SQLITE_ERROR if something goes 
  wrong. If an error occurs and pzErrMsg is not 0, then the 
  sqlite3_load_extension() interface shall attempt to fill *pzErrMsg with error 
  message text stored in memory obtained from sqlite3_malloc(). The calling 
  function should free this memory by calling sqlite3_free().

  Extension loading must be enabled using sqlite3_enable_load_extension() or 
  sqlite3_db_config(db,SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION,1,NULL) prior to 
  calling this API, otherwise an error will be returned.

  Security warning: It is recommended that the 
  SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION method be used to enable only this 
  interface. The use of the sqlite3_enable_load_extension() interface should be 
  avoided. This will keep the SQL function load_extension() disabled and prevent 
  SQL injections from giving attackers access to extension loading 
  capabilities. }
function sqlite3_load_extension(db : psqlite3; const zFile : PChar; 
  const zProc : PChar; pzErrMsg : PPChar) : Integer; cdecl; 
  external sqlite3_lib;

{ So as not to open security holes in older applications that are unprepared to 
  deal with extension loading, and as a means of disabling extension loading 
  while evaluating user-entered SQL, the following API is provided to turn the 
  sqlite3_load_extension() mechanism on and off.

  Extension loading is off by default. Call the sqlite3_enable_load_extension() 
  routine with onoff==1 to turn extension loading on and call it with onoff==0 
  to turn it back off again.

  This interface enables or disables both the C-API sqlite3_load_extension() and 
  the SQL function load_extension(). Use 
  sqlite3_db_config(db,SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION,..) to enable or 
  disable only the C-API.

  Security warning: It is recommended that extension loading be enabled using 
  the SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION method rather than this interface, 
  so the load_extension() SQL function remains disabled. This will prevent SQL 
  injections from giving attackers access to extension loading capabilities. }
function sqlite3_enable_load_extension(db : psqlite3; onoff : Integer) : 
  Integer; cdecl; external sqlite3_lib;

{ This interface causes the xEntryPoint() function to be invoked for each new 
  database connection that is created. The idea here is that xEntryPoint() is 
  the entry point for a statically linked SQLite extension that is to be 
  automatically loaded into all new database connections.

  Even though the function prototype shows that xEntryPoint() takes no arguments 
  and returns void, SQLite invokes xEntryPoint() with three arguments and 
  expects an integer result. 
  
  If the xEntryPoint routine encounters an error, it should make *pzErrMsg point 
  to an appropriate error message (obtained from sqlite3_mprintf()) and return 
  an appropriate error code. SQLite ensures that *pzErrMsg is NULL before 
  calling the xEntryPoint(). SQLite will invoke sqlite3_free() on *pzErrMsg 
  after xEntryPoint() returns. If any xEntryPoint() returns an error, the 
  sqlite3_open(), sqlite3_open16(), or sqlite3_open_v2() call that provoked the 
  xEntryPoint() will fail.

  Calling sqlite3_auto_extension(X) with an entry point X that is already on the 
  list of automatic extensions is a harmless no-op. No entry point will be 
  called more than once for each database connection that is opened. }
function sqlite3_auto_extension(xEntryPoint : xEntryPoint_callback) : Integer;
  cdecl; external sqlite3_lib;

{ The sqlite3_cancel_auto_extension(X) interface unregisters the initialization 
  routine X that was registered using a prior call to sqlite3_auto_extension(X). 
  The sqlite3_cancel_auto_extension(X) routine returns 1 if initialization 
  routine X was successfully unregistered and it returns 0 if X was not on the 
  list of initialization routines. }
function sqlite3_cancel_auto_extension(xEntryPoint : xEntryPoint_callback) : 
  Integer; cdecl; external sqlite3_lib;

{ This interface disables all automatic extensions previously registered using 
  sqlite3_auto_extension(). }
procedure sqlite3_reset_auto_extension; cdecl; external sqlite3_lib;

{ These routines are used to register a new virtual table module name. Module 
  names must be registered before creating a new virtual table using the module 
  and before using a preexisting virtual table for the module.

  The module name is registered on the database connection specified by the 
  first parameter. The name of the module is given by the second parameter. The 
  third parameter is a pointer to the implementation of the virtual table 
  module. The fourth parameter is an arbitrary client data pointer that is 
  passed through into the xCreate and xConnect methods of the virtual table 
  module when a new virtual table is be being created or reinitialized.

  The sqlite3_create_module_v2() interface has a fifth parameter which is a 
  pointer to a destructor for the pClientData. SQLite will invoke the destructor 
  function (if it is not NULL) when SQLite no longer needs the pClientData 
  pointer. The destructor will also be invoked if the call to 
  sqlite3_create_module_v2() fails. The sqlite3_create_module() interface is 
  equivalent to sqlite3_create_module_v2() with a NULL destructor.

  If the third parameter (the pointer to the sqlite3_module object) is NULL then 
  no new module is create and any existing modules with the same name are 
  dropped. }
function sqlite3_create_module(db : psqlite3; const zName : PChar; const p :
  psqlite3_module; pClientData : Pointer) : Integer; cdecl; 
  external sqlite3_lib;
function sqlite3_create_module_v2(db : psqlite3; const zName : PChar; const p :
  psqlite3_module; pClientData : Pointer; xDestroy : xDestroy_callback) : 
  Integer; cdecl; external sqlite3_lib;

{ The sqlite3_drop_modules(D,L) interface removes all virtual table modules from 
  database connection D except those named on list L. The L parameter must be 
  either NULL or a pointer to an array of pointers to strings where the array is 
  terminated by a single NULL pointer. If the L parameter is NULL, then all 
  virtual table modules are removed. }
function sqlite3_drop_modules(db : psqlite3; const azKeep : PPChar) : Integer;
  cdecl; external sqlite3_lib;

 { The xCreate and xConnect methods of a virtual table module call this 
  interface to declare the format (the names and datatypes of the columns) of 
  the virtual tables they implement. }
function sqlite3_declare_vtab(db : psqlite3; const zSQL : PChar) : Integer;
  cdecl; external sqlite3_lib;

{ Virtual tables can provide alternative implementations of functions using the 
  xFindFunction method of the virtual table module. But global versions of those 
  functions must exist in order to be overloaded.

  This API makes sure a global version of a function with a particular name and 
  number of parameters exists. If no such function exists before this API is 
  called, a new function is created. The implementation of the new function 
  always causes an exception to be thrown. So the new function is not good for 
  anything by itself. Its only purpose is to be a placeholder function that can 
  be overloaded by a virtual table. }
function sqlite3_overload_function(db : psqlite3; const zFuncName : PChar; 
  nArg : Integer) : Integer; cdecl; external sqlite3_lib;

{ This interfaces opens a handle to the BLOB located in row iRow, column 
  zColumn, table zTable in database zDb.
  
  Parameter zDb is not the filename that contains the database, but rather the 
  symbolic name of the database. For attached databases, this is the name that 
  appears after the AS keyword in the ATTACH statement. For the main database 
  file, the database name is "main". For TEMP tables, the database name is 
  "temp".

  If the flags parameter is non-zero, then the BLOB is opened for read and write 
  access. If the flags parameter is zero, the BLOB is opened for read-only 
  access.

  On success, SQLITE_OK is returned and the new BLOB handle is stored in 
  *ppBlob. Otherwise an error code is returned and, unless the error code is 
  SQLITE_MISUSE, *ppBlob is set to NULL. This means that, provided the API is 
  not misused, it is always safe to call sqlite3_blob_close() on *ppBlob after 
  this function it returns.

  This function fails with SQLITE_ERROR if any of the following are true:

    Database zDb does not exist,
    Table zTable does not exist within database zDb,
    Table zTable is a WITHOUT ROWID table,
    Column zColumn does not exist,
    Row iRow is not present in the table,
    The specified column of row iRow contains a value that is not a TEXT or BLOB 
      value,
    Column zColumn is part of an index, PRIMARY KEY or UNIQUE constraint and the 
      blob is being opened for read/write access,
    Foreign key constraints are enabled, column zColumn is part of a child key 
      definition and the blob is being opened for read/write access. 

  Unless it returns SQLITE_MISUSE, this function sets the database connection 
  error code and message accessible via sqlite3_errcode() and sqlite3_errmsg() 
  and related functions.

  A BLOB referenced by sqlite3_blob_open() may be read using the 
  sqlite3_blob_read() interface and modified by using sqlite3_blob_write(). The 
  BLOB handle can be moved to a different row of the same table using the 
  sqlite3_blob_reopen() interface. However, the column, table, or database of a 
  BLOB handle cannot be changed after the BLOB handle is opened.

  If the row that a BLOB handle points to is modified by an UPDATE, DELETE, or 
  by ON CONFLICT side-effects then the BLOB handle is marked as "expired". This 
  is true if any column of the row is changed, even a column other than the one 
  the BLOB handle is open on. Calls to sqlite3_blob_read() and 
  sqlite3_blob_write() for an expired BLOB handle fail with a return code of 
  SQLITE_ABORT. Changes written into a BLOB prior to the BLOB expiring are not 
  rolled back by the expiration of the BLOB. Such changes will eventually commit 
  if the transaction continues to completion.

  Use the sqlite3_blob_bytes() interface to determine the size of the opened 
  blob. The size of a blob may not be changed by this interface. Use the UPDATE 
  SQL command to change the size of a blob.

  The sqlite3_bind_zeroblob() and sqlite3_result_zeroblob() interfaces and the 
  built-in zeroblob SQL function may be used to create a zero-filled blob to 
  read or write using the incremental-blob interface.

  To avoid a resource leak, every open BLOB handle should eventually be released 
  by a call to sqlite3_blob_close(). }
function sqlite3_blob_open(db : psqlite3; const zDb : PChar; const zTable :
  PChar; const zColumn : PChar; iRow : sqlite3_int64; flags : Integer; ppBlob :
    ppsqlite3_blob) : Integer; cdecl; external sqlite3_lib;

{ This function is used to move an existing BLOB handle so that it points to a 
  different row of the same database table. The new row is identified by the 
  rowid value passed as the second argument. Only the row can be changed. The 
  database, table and column on which the blob handle is open remain the same. 
  Moving an existing BLOB handle to a new row is faster than closing the 
  existing handle and opening a new one.

  The new row must meet the same criteria as for sqlite3_blob_open() - it must 
  exist and there must be either a blob or text value stored in the nominated 
  column. If the new row is not present in the table, or if it does not contain 
  a blob or text value, or if another error occurs, an SQLite error code is 
  returned and the blob handle is considered aborted. All subsequent calls to 
  sqlite3_blob_read(), sqlite3_blob_write() or sqlite3_blob_reopen() on an 
  aborted blob handle immediately return SQLITE_ABORT. Calling 
  sqlite3_blob_bytes() on an aborted blob handle always returns zero.

  This function sets the database handle error code and message. }
function sqlite3_blob_reopen(pBlob : psqlite3_blob; iRow : sqlite3_int64) : 
  Integer; cdecl; external sqlite3_lib;

{ This function closes an open BLOB handle. The BLOB handle is closed 
  unconditionally. Even if this routine returns an error code, the handle is 
  still closed.

  If the blob handle being closed was opened for read-write access, and if the 
  database is in auto-commit mode and there are no other open read-write blob 
  handles or active write statements, the current transaction is committed. If 
  an error occurs while committing the transaction, an error code is returned 
  and the transaction rolled back.

  Calling this function with an argument that is not a NULL pointer or an open 
  blob handle results in undefined behaviour. Calling this routine with a null 
  pointer (such as would be returned by a failed call to sqlite3_blob_open()) is 
  a harmless no-op. Otherwise, if this function is passed a valid open blob 
  handle, the values returned by the sqlite3_errcode() and sqlite3_errmsg() 
  functions are set before returning. }
function sqlite3_blob_close(pBlob : psqlite3_blob) : Integer; cdecl;
  external sqlite3_lib;

{ Returns the size in bytes of the BLOB accessible via the successfully opened 
  BLOB handle in its only argument. The incremental blob I/O routines can only 
  read or overwriting existing blob content; they cannot change the size of a 
  blob.

  This routine only works on a BLOB handle which has been created by a prior 
  successful call to sqlite3_blob_open() and which has not been closed by 
  sqlite3_blob_close(). Passing any other pointer in to this routine results in 
  undefined and probably undesirable behavior. }
function sqlite3_blob_bytes(pBlob : psqlite3_blob) : Integer; cdecl;
  external sqlite3_lib;

{ This function is used to read data from an open BLOB handle into a 
  caller-supplied buffer. N bytes of data are copied into buffer Z from the open 
  BLOB, starting at offset iOffset.

  If offset iOffset is less than N bytes from the end of the BLOB, SQLITE_ERROR 
  is returned and no data is read. If N or iOffset is less than zero, 
  SQLITE_ERROR is returned and no data is read. The size of the blob (and hence 
  the maximum value of N+iOffset) can be determined using the 
  sqlite3_blob_bytes() interface.

  An attempt to read from an expired BLOB handle fails with an error code of 
  SQLITE_ABORT.

  On success, sqlite3_blob_read() returns SQLITE_OK. Otherwise, an error code or 
  an extended error code is returned.

  This routine only works on a BLOB handle which has been created by a prior 
  successful call to sqlite3_blob_open() and which has not been closed by 
  sqlite3_blob_close(). Passing any other pointer in to this routine results in 
  undefined and probably undesirable behavior. }
function sqlite3_blob_read(pBlob : psqlite3_blob; z : Pointer; N : Integer;
  iOffset : Integer) : Integer; cdecl; external sqlite3_lib;

{ This function is used to write data into an open BLOB handle from a 
  caller-supplied buffer. N bytes of data are copied from the buffer Z into the 
  open BLOB, starting at offset iOffset.

  On success, sqlite3_blob_write() returns SQLITE_OK. Otherwise, an error code 
  or an extended error code is returned. Unless SQLITE_MISUSE is returned, this 
  function sets the database connection error code and message accessible via 
  sqlite3_errcode() and sqlite3_errmsg() and related functions.

  If the BLOB handle passed as the first argument was not opened for writing 
  (the flags parameter to sqlite3_blob_open() was zero), this function returns 
  SQLITE_READONLY.

  This function may only modify the contents of the BLOB; it is not possible to 
  increase the size of a BLOB using this API. If offset iOffset is less than N 
  bytes from the end of the BLOB, SQLITE_ERROR is returned and no data is
  written. The size of the BLOB (and hence the maximum value of N+iOffset) can 
  be determined using the sqlite3_blob_bytes() interface. If N or iOffset are 
  less than zero SQLITE_ERROR is returned and no data is written.

  An attempt to write to an expired BLOB handle fails with an error code of 
  SQLITE_ABORT. Writes to the BLOB that occurred before the BLOB handle expired 
  are not rolled back by the expiration of the handle, though of course those 
  changes might have been overwritten by the statement that expired the BLOB 
  handle or by other independent statements.

  This routine only works on a BLOB handle which has been created by a prior 
  successful call to sqlite3_blob_open() and which has not been closed by 
  sqlite3_blob_close(). Passing any other pointer in to this routine results in 
  undefined and probably undesirable behavior. }
function sqlite3_blob_write(pBlob : psqlite3_blob; const z : Pointer; n : 
  Integer; iOffset : Integer) : Integer; cdecl; external sqlite3_lib;

{ A virtual filesystem (VFS) is an sqlite3_vfs object that SQLite uses to 
  interact with the underlying operating system. Most SQLite builds come with a 
  single default VFS that is appropriate for the host computer. New VFSes can be 
  registered and existing VFSes can be unregistered. The following interfaces 
  are provided.

  The sqlite3_vfs_find() interface returns a pointer to a VFS given its name. 
  Names are case sensitive. Names are zero-terminated UTF-8 strings. If there is 
  no match, a NULL pointer is returned. If zVfsName is NULL then the default VFS 
  is returned.

  New VFSes are registered with sqlite3_vfs_register(). Each new VFS becomes the 
  default VFS if the makeDflt flag is set. The same VFS can be registered 
  multiple times without injury. To make an existing VFS into the default VFS, 
  register it again with the makeDflt flag set. If two different VFSes with the 
  same name are registered, the behavior is undefined. If a VFS is registered 
  with a name that is NULL or an empty string, then the behavior is undefined.

  Unregister a VFS with the sqlite3_vfs_unregister() interface. If the default 
  VFS is unregistered, another VFS is chosen as the default. The choice for the 
  new VFS is arbitrary. }
function sqlite3_vfs_find(const zVfsName : PChar) : psqlite3_vfs; cdecl;
  external sqlite3_lib;
function sqlite3_vfs_register(pVfs : psqlite3_vfs; makeDflt : Integer) : 
  Integer; cdecl; external sqlite3_lib;
function sqlite3_vfs_unregister(pVfs : psqlite3_vfs) : Integer; cdecl;
  external sqlite3_lib;

{ The SQLite core uses these routines for thread synchronization. Though they 
  are intended for internal use by SQLite, code that links against SQLite is 
  permitted to use any of these routines.

  The SQLite source code contains multiple implementations of these mutex 
  routines. An appropriate implementation is selected automatically at 
  compile-time. The following implementations are available in the SQLite core:

    SQLITE_MUTEX_PTHREADS
    SQLITE_MUTEX_W32
    SQLITE_MUTEX_NOOP 

  The SQLITE_MUTEX_NOOP implementation is a set of routines that does no real 
  locking and is appropriate for use in a single-threaded application. The 
  SQLITE_MUTEX_PTHREADS and SQLITE_MUTEX_W32 implementations are appropriate for 
  use on Unix and Windows.

  If SQLite is compiled with the SQLITE_MUTEX_APPDEF preprocessor macro defined 
  (with "-DSQLITE_MUTEX_APPDEF=1"), then no mutex implementation is included 
  with the library. In this case the application must supply a custom mutex 
  implementation using the SQLITE_CONFIG_MUTEX option of the sqlite3_config() 
  function before calling sqlite3_initialize() or any other public sqlite3_ 
  function that calls sqlite3_initialize().

  The sqlite3_mutex_alloc() routine allocates a new mutex and returns a pointer 
  to it. The sqlite3_mutex_alloc() routine returns NULL if it is unable to 
  allocate the requested mutex. The argument to sqlite3_mutex_alloc() must one 
  of these integer constants:

    SQLITE_MUTEX_FAST
    SQLITE_MUTEX_RECURSIVE
    SQLITE_MUTEX_STATIC_MAIN
    SQLITE_MUTEX_STATIC_MEM
    SQLITE_MUTEX_STATIC_OPEN
    SQLITE_MUTEX_STATIC_PRNG
    SQLITE_MUTEX_STATIC_LRU
    SQLITE_MUTEX_STATIC_PMEM
    SQLITE_MUTEX_STATIC_APP1
    SQLITE_MUTEX_STATIC_APP2
    SQLITE_MUTEX_STATIC_APP3
    SQLITE_MUTEX_STATIC_VFS1
    SQLITE_MUTEX_STATIC_VFS2
    SQLITE_MUTEX_STATIC_VFS3 

  The first two constants (SQLITE_MUTEX_FAST and SQLITE_MUTEX_RECURSIVE) cause 
  sqlite3_mutex_alloc() to create a new mutex. The new mutex is recursive when 
  SQLITE_MUTEX_RECURSIVE is used but not necessarily so when SQLITE_MUTEX_FAST 
  is used. The mutex implementation does not need to make a distinction between 
  SQLITE_MUTEX_RECURSIVE and SQLITE_MUTEX_FAST if it does not want to. SQLite 
  will only request a recursive mutex in cases where it really needs one. If a 
  faster non-recursive mutex implementation is available on the host platform, 
  the mutex subsystem might return such a mutex in response to 
  SQLITE_MUTEX_FAST.

  The other allowed parameters to sqlite3_mutex_alloc() (anything other than 
  SQLITE_MUTEX_FAST and SQLITE_MUTEX_RECURSIVE) each return a pointer to a 
  static preexisting mutex. Nine static mutexes are used by the current version 
  of SQLite. Future versions of SQLite may add additional static mutexes. Static 
  mutexes are for internal use by SQLite only. Applications that use SQLite 
  mutexes should use only the dynamic mutexes returned by SQLITE_MUTEX_FAST or 
  SQLITE_MUTEX_RECURSIVE.

  Note that if one of the dynamic mutex parameters (SQLITE_MUTEX_FAST or 
  SQLITE_MUTEX_RECURSIVE) is used then sqlite3_mutex_alloc() returns a different 
  mutex on every call. For the static mutex types, the same mutex is returned on 
  every call that has the same type number.

  The sqlite3_mutex_free() routine deallocates a previously allocated dynamic 
  mutex. Attempting to deallocate a static mutex results in undefined behavior.

  The sqlite3_mutex_enter() and sqlite3_mutex_try() routines attempt to enter a 
  mutex. If another thread is already within the mutex, sqlite3_mutex_enter() 
  will block and sqlite3_mutex_try() will return SQLITE_BUSY. The 
  sqlite3_mutex_try() interface returns SQLITE_OK upon successful entry. Mutexes 
  created using SQLITE_MUTEX_RECURSIVE can be entered multiple times by the same 
  thread. In such cases, the mutex must be exited an equal number of times 
  before another thread can enter. If the same thread tries to enter any mutex 
  other than an SQLITE_MUTEX_RECURSIVE more than once, the behavior is 
  undefined.

  Some systems (for example, Windows 95) do not support the operation 
  implemented by sqlite3_mutex_try(). On those systems, sqlite3_mutex_try() will 
  always return SQLITE_BUSY. The SQLite core only ever uses sqlite3_mutex_try() 
  as an optimization so this is acceptable behavior.

  The sqlite3_mutex_leave() routine exits a mutex that was previously entered by 
  the same thread. The behavior is undefined if the mutex is not currently 
  entered by the calling thread or is not currently allocated.

  If the argument to sqlite3_mutex_enter(), sqlite3_mutex_try(), or 
  sqlite3_mutex_leave() is a NULL pointer, then all three routines behave as 
  no-ops. }
function sqlite3_mutex_alloc(id : Integer) : psqlite3_mutex; cdecl;
  external sqlite3_lib;
procedure sqlite3_mutex_free(p : psqlite3_mutex); cdecl; external sqlite3_lib;
procedure sqlite3_mutex_enter(p : psqlite3_mutex); cdecl; external sqlite3_lib;
function sqlite3_mutex_try(p : psqlite3_mutex) : Integer; cdecl;
  external sqlite3_lib;
procedure sqlite3_mutex_leave(p : psqlite3_mutex); cdecl; external sqlite3_lib;

{ The sqlite3_mutex_held() and sqlite3_mutex_notheld() routines are intended for 
  use inside assert() statements. The SQLite core never uses these routines 
  except inside an assert() and applications are advised to follow the lead of 
  the core. The SQLite core only provides implementations for these routines 
  when it is compiled with the SQLITE_DEBUG flag. External mutex implementations 
  are only required to provide these routines if SQLITE_DEBUG is defined and if 
  NDEBUG is not defined.

  These routines should return true if the mutex in their argument is held or 
  not held, respectively, by the calling thread.

  The implementation is not required to provide versions of these routines that 
  actually work. If the implementation does not provide working versions of 
  these routines, it should at least provide stubs that always return true so 
  that one does not get spurious assertion failures.

  If the argument to sqlite3_mutex_held() is a NULL pointer then the routine 
  should return 1. This seems counter-intuitive since clearly the mutex cannot 
  be held if it does not exist. But the reason the mutex does not exist is 
  because the build is not using mutexes. And we do not want the assert() 
  containing the call to sqlite3_mutex_held() to fail, so a non-zero return is 
  the appropriate thing to do. The sqlite3_mutex_notheld() interface should also 
  return 1 when given a NULL pointer. }
function sqlite3_mutex_held(p : psqlite3_mutex) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_mutex_notheld(p : psqlite3_mutex) : Integer; cdecl;
  external sqlite3_lib;

{ This interface returns a pointer the sqlite3_mutex object that serializes 
  access to the database connection given in the argument when the threading 
  mode is Serialized. If the threading mode is Single-thread or Multi-thread 
  then this routine returns a NULL pointer. }
function sqlite3_db_mutex(db : psqlite3) : psqlite3_mutex; cdecl;
  external sqlite3_lib;

{ The sqlite3_file_control() interface makes a direct call to the xFileControl 
  method for the sqlite3_io_methods object associated with a particular database 
  identified by the second argument. The name of the database is "main" for the 
  main database or "temp" for the TEMP database, or the name that appears after 
  the AS keyword for databases that are added using the ATTACH SQL command. A 
  NULL pointer can be used in place of "main" to refer to the main database 
  file. The third and fourth parameters to this routine are passed directly 
  through to the second and third parameters of the xFileControl method. The 
  return value of the xFileControl method becomes the return value of this 
  routine.

  A few opcodes for sqlite3_file_control() are handled directly by the SQLite 
  core and never invoke the sqlite3_io_methods.xFileControl method. The 
  SQLITE_FCNTL_FILE_POINTER value for the op parameter causes a pointer to the 
  underlying sqlite3_file object to be written into the space pointed to by the 
  4th parameter. The SQLITE_FCNTL_JOURNAL_POINTER works similarly except that it 
  returns the sqlite3_file object associated with the journal file instead of 
  the main database. The SQLITE_FCNTL_VFS_POINTER opcode returns a pointer to 
  the underlying sqlite3_vfs object for the file. The SQLITE_FCNTL_DATA_VERSION 
  returns the data version counter from the pager.

  If the second parameter (zDbName) does not match the name of any open database 
  file, then SQLITE_ERROR is returned. This error code is not remembered and 
  will not be recalled by sqlite3_errcode() or sqlite3_errmsg(). The underlying 
  xFileControl method might also return SQLITE_ERROR. There is no way to 
  distinguish between an incorrect zDbName and an SQLITE_ERROR return from the 
  underlying xFileControl method. }
function sqlite3_file_control(db : psqlite3; const zDbName : PChar; op :
  Integer; pArg : Pointer) : Integer; cdecl; external sqlite3_lib;

{ The sqlite3_test_control() interface is used to read out internal state of 
  SQLite and to inject faults into SQLite for testing purposes. The first 
  parameter is an operation code that determines the number, meaning, and 
  operation of all subsequent parameters.

  This interface is not for use by applications. It exists solely for verifying 
  the correct operation of the SQLite library. Depending on how the SQLite 
  library is compiled, this interface might not exist.

  The details of the operation codes, their meanings, the parameters they take, 
  and what they do are all subject to change without notice. Unlike most of the 
  SQLite API, this function is not guaranteed to operate consistently from one 
  release to the next. }
function sqlite3_test_control(op : Integer) : Integer; cdecl; varargs;
  external sqlite3_lib;

{ These routines provide access to the set of SQL language keywords recognized 
  by SQLite. Applications can uses these routines to determine whether or not a 
  specific identifier needs to be escaped (for example, by enclosing in 
  double-quotes) so as not to confuse the parser.

  The sqlite3_keyword_count() interface returns the number of distinct keywords 
  understood by SQLite.

  The sqlite3_keyword_name(N,Z,L) interface finds the N-th keyword and makes *Z 
  point to that keyword expressed as UTF8 and writes the number of bytes in the 
  keyword into *L. The string that *Z points to is not zero-terminated. The 
  sqlite3_keyword_name(N,Z,L) routine returns SQLITE_OK if N is within bounds 
  and SQLITE_ERROR if not. If either Z or L are NULL or invalid pointers then 
  calls to sqlite3_keyword_name(N,Z,L) result in undefined behavior.

  The sqlite3_keyword_check(Z,L) interface checks to see whether or not the 
  L-byte UTF8 identifier that Z points to is a keyword, returning non-zero if it 
  is and zero if not.

  The parser used by SQLite is forgiving. It is often possible to use a keyword 
  as an identifier as long as such use does not result in a parsing ambiguity. 
  For example, the statement "CREATE TABLE BEGIN(REPLACE,PRAGMA,END);" is 
  accepted by SQLite, and creates a new table named "BEGIN" with three columns 
  named "REPLACE", "PRAGMA", and "END". Nevertheless, best practice is to avoid 
  using keywords as identifiers. Common techniques used to avoid keyword name 
  collisions include:

    Put all identifier names inside double-quotes. This is the official SQL way 
      to escape identifier names.
    Put identifier names inside [...]. This is not standard SQL, but it is what 
      SQL Server does and so lots of programmers use this technique.
    Begin every identifier with the letter "Z" as no SQL keywords start with 
      "Z".
    Include a digit somewhere in every identifier name. 

  Note that the number of keywords understood by SQLite can depend on 
  compile-time options. For example, "VACUUM" is not a keyword if SQLite is 
  compiled with the -DSQLITE_OMIT_VACUUM option. Also, new keywords may be added 
  to future releases of SQLite. }
function sqlite3_keyword_count : Integer; cdecl; external sqlite3_lib;
function sqlite3_keyword_name(i : Integer; const pzName : PPChar; pnName :
  PInteger) : Integer; cdecl; external sqlite3_lib;
function sqlite3_keyword_check(const zName : PChar; nName : Integer) : Integer;
  cdecl; external sqlite3_lib;

{ The sqlite3_str_new(D) interface allocates and initializes a new sqlite3_str 
  object. To avoid memory leaks, the object returned by sqlite3_str_new() must 
  be freed by a subsequent call to sqlite3_str_finish(X).

  The sqlite3_str_new(D) interface always returns a pointer to a valid 
  sqlite3_str object, though in the event of an out-of-memory error the returned 
  object might be a special singleton that will silently reject new text, always 
  return SQLITE_NOMEM from sqlite3_str_errcode(), always return 0 for 
  sqlite3_str_length(), and always return NULL from sqlite3_str_finish(X). It is 
  always safe to use the value returned by sqlite3_str_new(D) as the sqlite3_str 
  parameter to any of the other sqlite3_str methods.

  The D parameter to sqlite3_str_new(D) may be NULL. If the D parameter in 
  sqlite3_str_new(D) is not NULL, then the maximum length of the string 
  contained in the sqlite3_str object will be the value set for 
  sqlite3_limit(D,SQLITE_LIMIT_LENGTH) instead of SQLITE_MAX_LENGTH. }
function sqlite3_str_new(db : psqlite3) : psqlite3_str; cdecl;
  external sqlite3_lib;

{ The sqlite3_str_finish(X) interface destroys the sqlite3_str object X and 
  returns a pointer to a memory buffer obtained from sqlite3_malloc64() that 
  contains the constructed string. The calling application should pass the 
  returned value to sqlite3_free() to avoid a memory leak. The 
  sqlite3_str_finish(X) interface may return a NULL pointer if any errors were 
  encountered during construction of the string. The sqlite3_str_finish(X) 
  interface will also return a NULL pointer if the string in sqlite3_str object
  X is zero bytes long. }
function sqlite3_str_finish(p : psqlite3_str) :  PChar; cdecl;
  external sqlite3_lib;

{ These interfaces add content to an sqlite3_str object previously obtained from 
  sqlite3_str_new().

  The sqlite3_str_appendf(X,F,...) and sqlite3_str_vappendf(X,F,V) interfaces 
  uses the built-in printf functionality of SQLite to append formatted text onto 
  the end of sqlite3_str object X.

  The sqlite3_str_append(X,S,N) method appends exactly N bytes from string S 
  onto the end of the sqlite3_str object X. N must be non-negative. S must 
  contain at least N non-zero bytes of content. To append a zero-terminated 
  string in its entirety, use the sqlite3_str_appendall() method instead.

  The sqlite3_str_appendall(X,S) method appends the complete content of 
  zero-terminated string S onto the end of sqlite3_str object X.

  The sqlite3_str_appendchar(X,N,C) method appends N copies of the single-byte 
  character C onto the end of sqlite3_str object X. This method can be used, for 
  example, to add whitespace indentation.

  The sqlite3_str_reset(X) method resets the string under construction inside 
  sqlite3_str object X back to zero bytes in length.

  These methods do not return a result code. If an error occurs, that fact is 
  recorded in the sqlite3_str object and can be recovered by a subsequent call 
  to sqlite3_str_errcode(X). }
procedure sqlite3_str_appendf(p : psqlite3_str; const zFormat : PChar); cdecl;
  varargs; external sqlite3_lib;
procedure sqlite3_str_vappendf(p : psqlite3_str; const zFormat : PChar; 
  va_list : array of const); cdecl; external sqlite3_lib;
procedure sqlite3_str_append(p : psqlite3_str; const zIn : PChar; N : Integer);
  cdecl; external sqlite3_lib;
procedure sqlite3_str_appendall(p : psqlite3_str; const zIn : PChar); cdecl;
  external sqlite3_lib;
procedure sqlite3_str_appendchar(p : psqlite3_str; N : Integer; C : char);
  cdecl; external sqlite3_lib;
procedure sqlite3_str_reset(p : psqlite3_str); cdecl; external sqlite3_lib;

{ These interfaces return the current status of an sqlite3_str object.

  If any prior errors have occurred while constructing the dynamic string in 
  sqlite3_str X, then the sqlite3_str_errcode(X) method will return an 
  appropriate error code. The sqlite3_str_errcode(X) method returns SQLITE_NOMEM 
  following any out-of-memory error, or SQLITE_TOOBIG if the size of the dynamic 
  string exceeds SQLITE_MAX_LENGTH, or SQLITE_OK if there have been no errors.

  The sqlite3_str_length(X) method returns the current length, in bytes, of the 
  dynamic string under construction in sqlite3_str object X. The length returned 
  by sqlite3_str_length(X) does not include the zero-termination byte.

  The sqlite3_str_value(X) method returns a pointer to the current content of 
  the dynamic string under construction in X. The value returned by 
  sqlite3_str_value(X) is managed by the sqlite3_str object X and might be freed 
  or altered by any subsequent method on the same sqlite3_str object. 
  Applications must not used the pointer returned sqlite3_str_value(X) after any 
  subsequent method call on the same object. Applications may change the content 
  of the string returned by sqlite3_str_value(X) as long as they do not write 
  into any bytes outside the range of 0 to sqlite3_str_length(X) and do not read 
  or write any byte after any subsequent sqlite3_str method call. }
function sqlite3_str_errcode(p : psqlite3_str) : Integer; cdecl; 
  external sqlite3_lib;
function sqlite3_str_length(p : psqlite3_str) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_str_value(p : psqlite3_str) : PChar; cdecl;
  external sqlite3_lib;

{ These interfaces are used to retrieve runtime status information about the 
  performance of SQLite, and optionally to reset various highwater marks. The 
  first argument is an integer code for the specific parameter to measure.
  Recognized integer codes are of the form SQLITE_STATUS_.... The current value 
  of the parameter is returned into *pCurrent. The highest recorded value is 
  returned in *pHighwater. If the resetFlag is true, then the highest record 
  value is reset after *pHighwater is written. Some parameters do not record the 
  highest value. For those parameters nothing is written into *pHighwater and 
  the resetFlag is ignored. Other parameters record only the highwater mark and 
  not the current value. For these latter parameters nothing is written into 
  *pCurrent.

  The sqlite3_status() and sqlite3_status64() routines return SQLITE_OK on 
  success and a non-zero error code on failure.

  If either the current value or the highwater mark is too large to be 
  represented by a 32-bit integer, then the values returned by sqlite3_status() 
  are undefined. }
function sqlite3_status(op : Integer; pCurrent : PInteger; pHighweter : 
  PInteger; resetFlag : Integer) : Integer; cdecl; external sqlite3_lib;
function sqlite3_status64(op : Integer; pCurrent : psqlite3_int64; pHighwater :
  psqlite3_int64; resetFlag : Integer) : Integer; cdecl; external sqlite3_lib;

{ This interface is used to retrieve runtime status information about a single 
  database connection. The first argument is the database connection object to 
  be interrogated. The second argument is an integer constant, taken from the 
  set of SQLITE_DBSTATUS options, that determines the parameter to interrogate. 
  The set of SQLITE_DBSTATUS options is likely to grow in future releases of 
  SQLite.

  The current value of the requested parameter is written into *pCur and the 
  highest instantaneous value is written into *pHiwtr. If the resetFlg is true, 
  then the highest instantaneous value is reset back down to the current value.

  The sqlite3_db_status() routine returns SQLITE_OK on success and a non-zero 
  error code on failure. }
function sqlite3_db_status(db : psqlite3; op : Integer; pCur : PInteger;
  pHiwtr : PInteger; resetFlg : Integer) : Integer; cdecl;
  external sqlite3_lib;

{ Each prepared statement maintains various SQLITE_STMTSTATUS counters that 
  measure the number of times it has performed specific operations. These 
  counters can be used to monitor the performance characteristics of the 
  prepared statements. For example, if the number of table steps greatly exceeds 
  the number of table searches or result rows, that would tend to indicate that 
  the prepared statement is using a full table scan rather than an index.

  This interface is used to retrieve and reset counter values from a prepared 
  statement. The first argument is the prepared statement object to be 
  interrogated. The second argument is an integer code for a specific 
  SQLITE_STMTSTATUS counter to be interrogated. The current value of the 
  requested counter is returned. If the resetFlg is true, then the counter is 
  reset to zero after this interface call returns. }
function sqlite3_stmt_status(pStmt : psqlite3_stmt; op : Integer; resetFlg :
  Integer) : Integer; cdecl; external sqlite3_lib;

{ The backup API copies the content of one database into another. It is useful 
  either for creating backups of databases or for copying in-memory databases to 
  or from persistent files. 

  SQLite holds a write transaction open on the destination database file for the 
  duration of the backup operation. The source database is read-locked only 
  while it is being read; it is not locked continuously for the entire backup 
  operation. Thus, the backup may be performed on a live source database without 
  preventing other database connections from reading or writing to the source 
  database while the backup is underway.

  To perform a backup operation:

    sqlite3_backup_init() is called once to initialize the backup,
    sqlite3_backup_step() is called one or more times to transfer the data 
      between the two databases, and finally
    sqlite3_backup_finish() is called to release all resources associated with 
      the backup operation. 

  There should be exactly one call to sqlite3_backup_finish() for each 
  successful call to sqlite3_backup_init(). }

{ The D and N arguments to sqlite3_backup_init(D,N,S,M) are the database 
  connection associated with the destination database and the database name, 
  respectively. The database name is "main" for the main database, "temp" for 
  the temporary database, or the name specified after the AS keyword in an 
  ATTACH statement for an attached database. The S and M arguments passed to 
  sqlite3_backup_init(D,N,S,M) identify the database connection and database 
  name of the source database, respectively. The source and destination database 
  connections (parameters S and D) must be different or else 
  sqlite3_backup_init(D,N,S,M) will fail with an error.

  A call to sqlite3_backup_init() will fail, returning NULL, if there is already 
  a read or read-write transaction open on the destination database.

  If an error occurs within sqlite3_backup_init(D,N,S,M), then NULL is returned 
  and an error code and error message are stored in the destination database 
  connection D. The error code and message for the failed call to 
  sqlite3_backup_init() can be retrieved using the sqlite3_errcode(), 
  sqlite3_errmsg(), and/or sqlite3_errmsg16() functions. A successful call to 
  sqlite3_backup_init() returns a pointer to an sqlite3_backup object. The 
  sqlite3_backup object may be used with the sqlite3_backup_step() and 
  sqlite3_backup_finish() functions to perform the specified backup operation. }
function sqlite3_backup_init(pDest : psqlite3; const zDestName : PChar; 
  pSource : psqlite3; const zSourceName : PChar) : psqlite3_backup; cdecl;
  external sqlite3_lib;

{ Function sqlite3_backup_step(B,N) will copy up to N pages between the source 
  and destination databases specified by sqlite3_backup object B. If N is 
  negative, all remaining source pages are copied. If sqlite3_backup_step(B,N) 
  successfully copies N pages and there are still more pages to be copied, then 
  the function returns SQLITE_OK. If sqlite3_backup_step(B,N) successfully 
  finishes copying all pages from source to destination, then it returns 
  SQLITE_DONE. If an error occurs while running sqlite3_backup_step(B,N), then 
  an error code is returned. As well as SQLITE_OK and SQLITE_DONE, a call to 
  sqlite3_backup_step() may return SQLITE_READONLY, SQLITE_NOMEM, SQLITE_BUSY, 
  SQLITE_LOCKED, or an SQLITE_IOERR_XXX extended error code.

  The sqlite3_backup_step() might return SQLITE_READONLY if

    the destination database was opened read-only, or
    the destination database is using write-ahead-log journaling and the 
      destination and source page sizes differ, or
    the destination database is an in-memory database and the destination and 
      source page sizes differ. 

  If sqlite3_backup_step() cannot obtain a required file-system lock, then the 
  busy-handler function is invoked (if one is specified). If the busy-handler 
  returns non-zero before the lock is available, then SQLITE_BUSY is returned to 
  the caller. In this case the call to sqlite3_backup_step() can be retried 
  later. If the source database connection is being used to write to the source 
  database when sqlite3_backup_step() is called, then SQLITE_LOCKED is returned 
  immediately. Again, in this case the call to sqlite3_backup_step() can be 
  retried later on. If SQLITE_IOERR_XXX, SQLITE_NOMEM, or SQLITE_READONLY is 
  returned, then there is no point in retrying the call to 
  sqlite3_backup_step(). These errors are considered fatal. The application must 
  accept that the backup operation has failed and pass the backup operation 
  handle to the sqlite3_backup_finish() to release associated resources.

  The first call to sqlite3_backup_step() obtains an exclusive lock on the 
  destination file. The exclusive lock is not released until either 
  sqlite3_backup_finish() is called or the backup operation is complete and 
  sqlite3_backup_step() returns SQLITE_DONE. Every call to sqlite3_backup_step() 
  obtains a shared lock on the source database that lasts for the duration of 
  the sqlite3_backup_step() call. Because the source database is not locked 
  between calls to sqlite3_backup_step(), the source database may be modified
  mid-way through the backup process. If the source database is modified by an 
  external process or via a database connection other than the one being used by 
  the backup operation, then the backup will be automatically restarted by the 
  next call to sqlite3_backup_step(). If the source database is modified by the 
  using the same database connection as is used by the backup operation, then 
  the backup database is automatically updated at the same time. }
function sqlite3_backup_step(p : psqlite3_backup; nPage : Integer) : Integer;
  cdecl; external sqlite3_lib;

{ When sqlite3_backup_step() has returned SQLITE_DONE, or when the application 
  wishes to abandon the backup operation, the application should destroy the 
  sqlite3_backup by passing it to sqlite3_backup_finish(). The 
  sqlite3_backup_finish() interfaces releases all resources associated with the 
  sqlite3_backup object. If sqlite3_backup_step() has not yet returned 
  SQLITE_DONE, then any active write-transaction on the destination database is 
  rolled back. The sqlite3_backup object is invalid and may not be used 
  following a call to sqlite3_backup_finish().

  The value returned by sqlite3_backup_finish is SQLITE_OK if no 
  sqlite3_backup_step() errors occurred, regardless or whether or not 
  sqlite3_backup_step() completed. If an out-of-memory condition or IO error 
  occurred during any prior sqlite3_backup_step() call on the same 
  sqlite3_backup object, then sqlite3_backup_finish() returns the corresponding 
  error code.

  A return of SQLITE_BUSY or SQLITE_LOCKED from sqlite3_backup_step() is not a 
  permanent error and does not affect the return value of 
  sqlite3_backup_finish(). }
function sqlite3_backup_finish(p : psqlite3_backup) : Integer; cdecl;
  external sqlite3_lib;

{ The sqlite3_backup_remaining() routine returns the number of pages still to be 
  backed up at the conclusion of the most recent sqlite3_backup_step(). The 
  sqlite3_backup_pagecount() routine returns the total number of pages in the 
  source database at the conclusion of the most recent sqlite3_backup_step(). 
  The values returned by these functions are only updated by 
  sqlite3_backup_step(). If the source database is modified in a way that 
  changes the size of the source database or the number of pages remaining, 
  those changes are not reflected in the output of sqlite3_backup_pagecount() 
  and sqlite3_backup_remaining() until after the next sqlite3_backup_step().

  Concurrent Usage of Database Handles

  The source database connection may be used by the application for other 
  purposes while a backup operation is underway or being initialized. If SQLite 
  is compiled and configured to support threadsafe database connections, then 
  the source database connection may be used concurrently from within other 
  threads.

  However, the application must guarantee that the destination database 
  connection is not passed to any other API (by any thread) after 
  sqlite3_backup_init() is called and before the corresponding call to 
  sqlite3_backup_finish(). SQLite does not currently check to see if the 
  application incorrectly accesses the destination database connection and so no 
  error code is reported, but the operations may malfunction nevertheless. Use 
  of the destination database connection while a backup is in progress might 
  also also cause a mutex deadlock.

  If running in shared cache mode, the application must guarantee that the 
  shared cache used by the destination database is not accessed while the backup 
  is running. In practice this means that the application must guarantee that 
  the disk file being backed up to is not accessed by any connection within the 
  process, not just the specific connection that was passed to 
  sqlite3_backup_init().

  The sqlite3_backup object itself is partially threadsafe. Multiple threads may 
  safely make multiple concurrent calls to sqlite3_backup_step(). However, the 
  sqlite3_backup_remaining() and sqlite3_backup_pagecount() APIs are not 
  strictly speaking threadsafe. If they are invoked at the same time as another 
  thread is invoking sqlite3_backup_step() it is possible that they return 
  invalid values. }
function sqlite3_backup_remaining(p : psqlite3_backup) : Integer; cdecl;
  external sqlite3_lib;
function sqlite3_backup_pagecount(p : psqlite3_backup) : Integer; cdecl;
  external sqlite3_lib;





implementation

end.