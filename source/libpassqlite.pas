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


type
  PPChar = ^PChar;
  PPointer = ^Pointer;
  
  psqlite3_int64 = ^sqlite3_int64;
  sqlite3_int64 = type Int64;

  psqlite3_uint64 = ^sqlite3_uint64;
  sqlite3_uint64 = type QWord;

  sqlite3_callback = function(pArg : Pointer; nCol : Integer; azVals : PPChar;
    azCols : PPChar) : Integer of object;

  sqlite3_syscall_ptr = procedure of object;

  { Strutures forward declarations. }
  psqlite3 = ^sqlite3;
  psqlite3_file = ^sqlite3_file;
  psqlite3_io_methods = ^sqlite3_io_methods;
  psqlite3_mutex = ^sqlite3_mutex;
  psqlite3_api_routines = ^sqlite3_api_routines;
  psqlite3_vfs = ^sqlite3_vfs;

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



implementation

end.