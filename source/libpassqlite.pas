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

type
  PPPChar = ^PPChar;
  PPChar = ^PChar;
  PPointer = ^Pointer;
  
  psqlite3_int64 = ^sqlite3_int64;
  sqlite3_int64 = type Int64;

  psqlite3_uint64 = ^sqlite3_uint64;
  sqlite3_uint64 = type QWord;

  sqlite3_callback = function(pArg : Pointer; nCol : Integer; azVals : PPChar;
    azCols : PPChar) : Integer of object;

  sqlite3_syscall_ptr = procedure of object;

  xBusy_callback = function (ptr : Pointer; invoked : Integer) : Integer of 
    object;
  xAuth_callback = function (pAuthArg : Pointer; action_code : Integer; 
    const zArg1 : PChar; const zArg2 : PChar; const zArg3 : PChar; const zArg4 :
    PChar) : Integer of object;

  { Strutures forward declarations. }
  psqlite3 = ^sqlite3;
  psqlite3_file = ^sqlite3_file;
  psqlite3_io_methods = ^sqlite3_io_methods;
  psqlite3_mutex = ^sqlite3_mutex;
  psqlite3_api_routines = ^sqlite3_api_routines;
  psqlite3_vfs = ^sqlite3_vfs;
  psqlite3_mem_methods = ^sqlite3_mem_methods;

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



implementation

end.