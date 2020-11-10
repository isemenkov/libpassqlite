(******************************************************************************)
(*                                libPasSQLite                                *)
(*               object pascal wrapper around SQLite library                  *)
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
unit sqlite3.code;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  libpassqlite;

type
  TSQLite3Code = (
    { The SQLITE_OK result code means that the operation was successful and that 
      there were no errors. }
    SQLITE_OK = Longint(libpassqlite.SQLITE_OK),

    { The SQLITE_ERROR result code is a generic error code that is used when no 
      other more specific error code is available. }
    SQLITE_ERROR = Longint(libpassqlite.SQLITE_ERROR),

    { The SQLITE_INTERNAL result code indicates an internal malfunction. In a 
      working version of SQLite, an application should never see this result 
      code. If application does encounter this result code, it shows that there 
      is a bug in the database engine. }
    SQLITE_INTERNAL = Longint(libpassqlite.SQLITE_INTERNAL),

    { The SQLITE_PERM result code indicates that the requested access mode for a 
      newly created database could not be provided.  }
    SQLITE_PERM = Longint(libpassqlite.SQLITE_PERM),

    { The SQLITE_ABORT result code indicates that an operation was aborted prior 
      to completion, usually be application request. }
    SQLITE_ABORT = Longint(libpassqlite.SQLITE_ABORT),

    { The SQLITE_BUSY result code indicates that the database file could not be 
      written (or in some cases read) because of concurrent activity by some 
      other database connection, usually a database connection in a separate 
      process. }
    SQLITE_BUSY = Longint(libpassqlite.SQLITE_BUSY),

    { The SQLITE_LOCKED result code indicates that a write operation could not 
      continue because of a conflict within the same database connection or a 
      conflict with a different database connection that uses a shared cache. }
    SQLITE_LOCKED = Longint(libpassqlite.SQLITE_LOCKED),
    
    { The SQLITE_NOMEM result code indicates that SQLite was unable to allocate 
      all the memory it needed to complete the operation. }
    SQLITE_NOMEM = Longint(libpassqlite.SQLITE_NOMEM),

    { The SQLITE_READONLY result code is returned when an attempt is made to 
      alter some data for which the current database connection does not have 
      write permission. }
    SQLITE_READONLY = Longint(libpassqlite.SQLITE_READONLY),

    { The SQLITE_INTERRUPT result code indicates that an operation was 
      interrupted by the sqlite3_interrupt() interface. }
    SQLITE_INTERRUPT = Longint(libpassqlite.SQLITE_INTERRUPT),

    { The SQLITE_IOERR result code says that the operation could not finish 
      because the operating system reported an I/O error.  }
    SQLITE_IOERR = Longint(libpassqlite.SQLITE_IOERR),

    { The SQLITE_CORRUPT result code indicates that the database file has been 
      corrupted. }
    SQLITE_CORRUPT = Longint(libpassqlite.SQLITE_CORRUPT),

    SQLITE_NOTFOUND = Longint(libpassqlite.SQLITE_NOTFOUND),

    { The SQLITE_FULL result code indicates that a write could not complete 
      because the disk is full. }
    SQLITE_FULL = Longint(libpassqlite.SQLITE_FULL),

    { The SQLITE_CANTOPEN result code indicates that SQLite was unable to open a 
      file. }
    SQLITE_CANTOPEN = Longint(libpassqlite.SQLITE_CANTOPEN),

    { The SQLITE_PROTOCOL result code indicates a problem with the file locking 
      protocol used by SQLite. }
    SQLITE_PROTOCOL = Longint(libpassqlite.SQLITE_PROTOCOL),

    { The SQLITE_SCHEMA result code indicates that the database schema has 
      changed. }
    SQLITE_SCHEMA = Longint(libpassqlite.SQLITE_SCHEMA),

    { The SQLITE_TOOBIG error code indicates that a string or BLOB was too 
      large. }
    SQLITE_TOOBIG = Longint(libpassqlite.SQLITE_TOOBIG),

    { The SQLITE_CONSTRAINT error code means that an SQL constraint violation 
      occurred while trying to process an SQL statement. }
    SQLITE_CONSTRAINT = Longint(libpassqlite.SQLITE_CONSTRAINT),

    { The SQLITE_MISMATCH error code indicates a datatype mismatch. }
    SQLITE_MISMATCH = Longint(libpassqlite.SQLITE_MISMATCH),

    { The SQLITE_MISUSE return code might be returned if the application uses 
      any SQLite interface in a way that is undefined or unsupported. }
    SQLITE_MISUSE = Longint(libpassqlite.SQLITE_MISUSE),

    { The SQLITE_NOLFS error can be returned on systems that do not support 
      large files when the database grows to be larger than what the filesystem 
      can handle. "NOLFS" stands for "NO Large File Support". }
    SQLITE_NOLFS = Longint(libpassqlite.SQLITE_NOLFS),

    { The SQLITE_AUTH error is returned when the authorizer callback indicates 
      that an SQL statement being prepared is not authorized. }
    SQLITE_AUTH = Longint(libpassqlite.SQLITE_AUTH),

    { The SQLITE_RANGE error indices that the parameter number argument to one 
      of the sqlite3_bind routines or the column number in one of the 
      sqlite3_column routines is out of range. }
    SQLITE_RANGE = Longint(libpassqlite.SQLITE_RANGE),

    { When attempting to open a file, the SQLITE_NOTADB error indicates that the 
      file being opened does not appear to be an SQLite database file. }
    SQLITE_NOTADB = Longint(libpassqlite.SQLITE_NOTADB),

    { Indicate that an unusual operation is taking place. }
    SQLITE_NOTICE = Longint(libpassqlite.SQLITE_NOTICE),

    { Indicate that an unusual and possibly ill-advised operation is taking 
      place. }
    SQLITE_WARNING = Longint(libpassqlite.SQLITE_WARNING),

    { The SQLITE_ROW result code returned by sqlite3_step() indicates that 
      another row of output is available. }
    SQLITE_ROW = Longint(libpassqlite.SQLITE_ROW),

    { The SQLITE_DONE result code indicates that an operation has completed. }
    SQLITE_DONE = Longint(libpassqlite.SQLITE_DONE),

    SQLITE_OK_LOAD_PERMANENTLY 
      = Longint(libpassqlite.SQLITE_OK_LOAD_PERMANENTLY),

    { The SQLITE_ERROR_MISSING_COLLSEQ result code means that an SQL statement 
      could not be prepared because a collating sequence named in that SQL 
      statement could not be located. }
    SQLITE_ERROR_MISSING_COLLSEQ 
      = Longint(libpassqlite.SQLITE_ERROR_MISSING_COLLSEQ),

    { The SQLITE_BUSY_RECOVERY error code is an extended error code for 
      SQLITE_BUSY that indicates that an operation could not continue because 
      another process is busy recovering a WAL mode database file following a 
      crash. }
    SQLITE_BUSY_RECOVERY = Longint(libpassqlite.SQLITE_BUSY_RECOVERY),

    { The SQLITE_LOCKED_SHAREDCACHE error code is an extended error code for 
      SQLITE_LOCKED indicating that the locking conflict has occurred due to 
      contention with a different database connection that happens to hold a 
      shared cache with the database connection to which the error was 
      returned. }
    SQLITE_LOCKED_SHAREDCACHE = Longint(libpassqlite.SQLITE_LOCKED_SHAREDCACHE),

    { The SQLITE_READONLY_RECOVERY error code indicates that a WAL mode database 
      cannot be opened because the database file needs to be recovered and 
      recovery requires write access but only read access is available. }
    SQLITE_READONLY_RECOVERY = Longint(libpassqlite.SQLITE_READONLY_RECOVERY),

    { The SQLITE_IOERR_READ error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to read 
      from a file on disk. }
    SQLITE_IOERR_READ = Longint(libpassqlite.SQLITE_IOERR_READ),

    { The SQLITE_CORRUPT_VTAB error code is an extended error code for 
      SQLITE_CORRUPT used by virtual tables. A virtual table might return 
      SQLITE_CORRUPT_VTAB to indicate that content in the virtual table is 
      corrupt. }
    SQLITE_CORRUPT_VTAB = Longint(libpassqlite.SQLITE_CORRUPT_VTAB),

    { The SQLITE_CONSTRAINT_CHECK error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a CHECK constraint failed. }
    SQLITE_CONSTRAINT_CHECK = Longint(libpassqlite.SQLITE_CONSTRAINT_CHECK),

    { The SQLITE_NOTICE_RECOVER_WAL result code is passed to the callback of 
      sqlite3_log() when a WAL mode database file is recovered. }
    SQLITE_NOTICE_RECOVER_WAL = Longint(libpassqlite.SQLITE_NOTICE_RECOVER_WAL),

    { The SQLITE_WARNING_AUTOINDEX result code is passed to the callback of 
      sqlite3_log() whenever automatic indexing is used. This can serve as a 
      warning to application designers that the database might benefit from 
      additional indexes. }
    SQLITE_WARNING_AUTOINDEX = Longint(libpassqlite.SQLITE_WARNING_AUTOINDEX),

    { The SQLITE_ERROR_RETRY is used internally to provoke sqlite3_prepare_v2() 
      (or one of its sibling routines for creating prepared statements) to try 
      again to prepare a statement that failed with an error on the previous 
      attempt. }
    SQLITE_ERROR_RETRY = Longint(libpassqlite.SQLITE_ERROR_RETRY),

    { The SQLITE_ABORT_ROLLBACK error code is an extended error code for 
      SQLITE_ABORT indicating that an SQL statement aborted because the 
      transaction that was active when the SQL statement first started was 
      rolled back. }
    SQLITE_ABORT_ROLLBACK = Longint(libpassqlite.SQLITE_ABORT_ROLLBACK),

    { The SQLITE_BUSY_SNAPSHOT error code is an extended error code for 
      SQLITE_BUSY that occurs on WAL mode databases when a database connection 
      tries to promote a read transaction into a write transaction but finds 
      that another database connection has already written to the database and 
      thus invalidated prior reads. }
    SQLITE_BUSY_SNAPSHOT = Longint(libpassqlite.SQLITE_BUSY_SNAPSHOT),

    { The SQLITE_LOCKED_VTAB result code is not used by the SQLite core, but it 
      is available for use by extensions. Virtual table implementations can 
      return this result code to indicate that they cannot complete the current 
      operation because of locks held by other threads or processes. }
    SQLITE_LOCKED_VTAB = Longint(libpassqlite.SQLITE_LOCKED_VTAB),

    {  The SQLITE_READONLY_CANTLOCK error code indicates that SQLite is unable 
      to obtain a read lock on a WAL mode database because the shared-memory 
      file associated with that database is read-only. }
    SQLITE_READONLY_CANTLOCK = Longint(libpassqlite.SQLITE_READONLY_CANTLOCK),

    { Indicating that a read attempt in the VFS layer was unable to obtain as 
      many bytes as was requested. This might be due to a truncated file. }
    SQLITE_IOERR_SHORT_READ = Longint(libpassqlite.SQLITE_IOERR_SHORT_READ),

    { The SQLITE_CORRUPT_SEQUENCE result code means that the schema of the 
      sqlite_sequence table is corrupt. }
    SQLITE_CORRUPT_SEQUENCE = Longint(libpassqlite.SQLITE_CORRUPT_SEQUENCE),

    { The SQLITE_CANTOPEN_ISDIR error code is an extended error code for 
      SQLITE_CANTOPEN indicating that a file open operation failed because the 
      file is really a directory. }
    SQLITE_CANTOPEN_ISDIR = Longint(libpassqlite.SQLITE_CANTOPEN_ISDIR),

    { The SQLITE_CONSTRAINT_COMMITHOOK error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a commit hook callback returned non-zero 
      that thus caused the SQL statement to be rolled back. }
    SQLITE_CONSTRAINT_COMMITHOOK 
      = Longint(libpassqlite.SQLITE_CONSTRAINT_COMMITHOOK),

    { The SQLITE_NOTICE_RECOVER_ROLLBACK result code is passed to the callback 
      of sqlite3_log() when a hot journal is rolled back. }
    SQLITE_NOTICE_RECOVER_ROLLBACK 
      = Longint(libpassqlite.SQLITE_NOTICE_RECOVER_ROLLBACK),

    { The SQLITE_ERROR_SNAPSHOT result code might be returned when attempting to 
      start a read transaction on an historical version of the database by using 
      the sqlite3_snapshot_open() interface. If the historical snapshot is no 
      longer available, then the read transaction will fail with the 
      SQLITE_ERROR_SNAPSHOT. }
    SQLITE_ERROR_SNAPSHOT = Longint(libpassqlite.SQLITE_ERROR_SNAPSHOT),

    { The SQLITE_READONLY_ROLLBACK error code indicates that a database cannot 
      be opened because it has a hot journal that needs to be rolled back but 
      cannot because the database is readonly. }
    SQLITE_READONLY_ROLLBACK = Longint(libpassqlite.SQLITE_READONLY_ROLLBACK),

    { The SQLITE_IOERR_WRITE error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      write into a file on disk. }
    SQLITE_IOERR_WRITE = Longint(libpassqlite.SQLITE_IOERR_WRITE),

    { The SQLITE_CANTOPEN_FULLPATH error code is an extended error code for 
      SQLITE_CANTOPEN indicating that a file open operation failed because the 
      operating system was unable to convert the filename into a full pathname.}
    SQLITE_CANTOPEN_FULLPATH = Longint(libpassqlite.SQLITE_CANTOPEN_FULLPATH),

    { The SQLITE_CONSTRAINT_FOREIGNKEY error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a foreign key constraint failed. }
    SQLITE_CONSTRAINT_FOREIGNKEY 
      = Longint(libpassqlite.SQLITE_CONSTRAINT_FOREIGNKEY),

    { The SQLITE_READONLY_DBMOVED error code indicates that a database cannot be 
      modified because the database file has been moved since it was opened, and 
      so any attempt to modify the database might result in database corruption 
      if the processes crashes because the rollback journal would not be 
      correctly named. }
    SQLITE_READONLY_DBMOVED = Longint(libpassqlite.SQLITE_READONLY_DBMOVED),

    { The SQLITE_IOERR_FSYNC error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      flush previously written content out of OS and/or disk-control buffers and 
      into persistent storage. }
    SQLITE_IOERR_FSYNC = Longint(libpassqlite.SQLITE_IOERR_FSYNC),

    { The SQLITE_CANTOPEN_CONVPATH error code is an extended error code for 
      SQLITE_CANTOPEN used only by Cygwin VFS and indicating that the 
      cygwin_conv_path() system call failed while trying to open a file. }
    SQLITE_CANTOPEN_CONVPATH = Longint(libpassqlite.SQLITE_CANTOPEN_CONVPATH),

    SQLITE_CONSTRAINT_FUNCTION 
      = Longint(libpassqlite.SQLITE_CONSTRAINT_FUNCTION),

    { The SQLITE_READONLY_CANTINIT result code originates in the xShmMap method 
      of a VFS to indicate that the shared memory region used by WAL mode exists 
      buts its content is unreliable and unusable by the current process since 
      the current process does not have write permission on the shared memory 
      region. }
    SQLITE_READONLY_CANTINIT = Longint(libpassqlite.SQLITE_READONLY_CANTINIT),

    { The SQLITE_IOERR_DIR_FSYNC error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      invoke fsync() on a directory. }
    SQLITE_IOERR_DIR_FSYNC = Longint(libpassqlite.SQLITE_IOERR_DIR_FSYNC),

    { The SQLITE_CONSTRAINT_NOTNULL error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a NOT NULL constraint failed. }
    SQLITE_CONSTRAINT_NOTNULL = Longint(libpassqlite.SQLITE_CONSTRAINT_NOTNULL),

    { The SQLITE_READONLY_DIRECTORY result code indicates that the database is 
      read-only because process does not have permission to create a journal 
      file in the same directory as the database and the creation of a journal 
      file is a prerequisite for writing. }
    SQLITE_READONLY_DIRECTORY = Longint(libpassqlite.SQLITE_READONLY_DIRECTORY),

    { The SQLITE_IOERR_TRUNCATE error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      truncate a file to a smaller size. }
    SQLITE_IOERR_TRUNCATE = Longint(libpassqlite.SQLITE_IOERR_TRUNCATE),

    { The SQLITE_CONSTRAINT_PRIMARYKEY error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a PRIMARY KEY constraint failed. }
    SQLITE_CONSTRAINT_PRIMARYKEY 
      = Longint(libpassqlite.SQLITE_CONSTRAINT_PRIMARYKEY),

    { The SQLITE_IOERR_FSTAT error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the VFS layer while trying to 
      invoke fstat() (or the equivalent) on a file in order to determine 
      information such as the file size or access permissions. }
    SQLITE_IOERR_FSTAT = Longint(libpassqlite.SQLITE_IOERR_FSTAT),

    { The SQLITE_CONSTRAINT_TRIGGER error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a RAISE function within a trigger fired, 
      causing the SQL statement to abort. }
    SQLITE_CONSTRAINT_TRIGGER = Longint(libpassqlite.SQLITE_CONSTRAINT_TRIGGER),

    { The SQLITE_IOERR_UNLOCK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within xUnlock method on the 
      sqlite3_io_methods object. }
    SQLITE_IOERR_UNLOCK = Longint(libpassqlite.SQLITE_IOERR_UNLOCK),

    { The SQLITE_CONSTRAINT_UNIQUE error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a UNIQUE constraint failed. }
    SQLITE_CONSTRAINT_UNIQUE = Longint(libpassqlite.SQLITE_CONSTRAINT_UNIQUE),

    { The SQLITE_IOERR_UNLOCK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within xLock method on the 
      sqlite3_io_methods object while trying to obtain a read lock. }
    SQLITE_IOERR_RDLOCK = Longint(libpassqlite.SQLITE_IOERR_RDLOCK),

    { The SQLITE_CONSTRAINT_VTAB error code is not currently used by the SQLite 
      core. However, this error code is available for use by application-defined 
      virtual tables. }
    SQLITE_CONSTRAINT_VTAB = Longint(libpassqlite.SQLITE_CONSTRAINT_VTAB),

    { The SQLITE_IOERR_UNLOCK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within xDelete method on the 
      sqlite3_vfs object. }
    SQLITE_IOERR_DELETE = Longint(libpassqlite.SQLITE_IOERR_DELETE),

    { The SQLITE_CONSTRAINT_ROWID error code is an extended error code for 
      SQLITE_CONSTRAINT indicating that a rowid is not unique. }
    SQLITE_CONSTRAINT_ROWID = Longint(libpassqlite.SQLITE_CONSTRAINT_ROWID),

    { The SQLITE_IOERR_BLOCKED error code is no longer used. }
    SQLITE_IOERR_BLOCKED = Longint(libpassqlite.SQLITE_IOERR_BLOCKED),

    { The SQLITE_IOERR_NOMEM error code is sometimes returned by the VFS layer
      to indicate that an operation could not be completed due to the inability 
      to allocate sufficient memory. }
    SQLITE_IOERR_NOMEM = Longint(libpassqlite.SQLITE_IOERR_NOMEM),

    { The SQLITE_IOERR_ACCESS error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xAccess method on the 
      sqlite3_vfs object. }
    SQLITE_IOERR_ACCESS = Longint(libpassqlite.SQLITE_IOERR_ACCESS),

    { The SQLITE_IOERR_CHECKRESERVEDLOCK error code is an extended error code 
      for SQLITE_IOERR indicating an I/O error within the xCheckReservedLock 
      method on the sqlite3_io_methods object. }
    SQLITE_IOERR_CHECKRESERVEDLOCK 
      = Longint(libpassqlite.SQLITE_IOERR_CHECKRESERVEDLOCK),

    { The SQLITE_IOERR_LOCK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error in the advisory file locking logic. }
    SQLITE_IOERR_LOCK = Longint(libpassqlite.SQLITE_IOERR_LOCK),

    { The SQLITE_IOERR_ACCESS error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xClose method on the 
      sqlite3_io_methods object. }
    SQLITE_IOERR_CLOSE = Longint(libpassqlite.SQLITE_IOERR_CLOSE),

    { The SQLITE_IOERR_DIR_CLOSE error code is no longer used. }
    SQLITE_IOERR_DIR_CLOSE = Longint(libpassqlite.SQLITE_IOERR_DIR_CLOSE),

    { The SQLITE_IOERR_SHMOPEN error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xShmMap method on the 
      sqlite3_io_methods object while trying to open a new shared memory 
      segment. }
    SQLITE_IOERR_SHMOPEN = Longint(libpassqlite.SQLITE_IOERR_SHMOPEN),

    { The SQLITE_IOERR_SHMSIZE error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xShmMap method on the 
      sqlite3_io_methods object while trying to enlarge a "shm" file as part of 
      WAL mode transaction processing. This error may indicate that the 
      underlying filesystem volume is out of space. }
    SQLITE_IOERR_SHMSIZE = Longint(libpassqlite.SQLITE_IOERR_SHMSIZE),

    { The SQLITE_IOERR_SHMMAP error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xShmMap method on the 
      sqlite3_io_methods object while trying to map a shared memory segment into 
      the process address space. }
    SQLITE_IOERR_SHMMAP = Longint(libpassqlite.SQLITE_IOERR_SHMMAP),

    { The SQLITE_IOERR_SEEK error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xRead or xWrite methods on 
      the sqlite3_io_methods object while trying to seek a file descriptor to 
      the beginning point of the file where the read or write is to occur. }
    SQLITE_IOERR_SEEK = Longint(libpassqlite.SQLITE_IOERR_SEEK),

    { The SQLITE_IOERR_DELETE_NOENT error code is an extended error code for 
      SQLITE_IOERR indicating that the xDelete method on the sqlite3_vfs object 
      failed because the file being deleted does not exist. }
    SQLITE_IOERR_DELETE_NOENT = Longint(libpassqlite.SQLITE_IOERR_DELETE_NOENT),

    { The SQLITE_IOERR_MMAP error code is an extended error code for 
      SQLITE_IOERR indicating an I/O error within the xFetch or xUnfetch methods 
      on the sqlite3_io_methods object while trying to map or unmap part of the 
      database file into the process address space. }
    SQLITE_IOERR_MMAP = Longint(libpassqlite.SQLITE_IOERR_MMAP),

    { The SQLITE_IOERR_GETTEMPPATH error code is an extended error code for 
      SQLITE_IOERR indicating that the VFS is unable to determine a suitable 
      directory in which to place temporary files. }
    SQLITE_IOERR_GETTEMPPATH = Longint(libpassqlite.SQLITE_IOERR_GETTEMPPATH),

    { The SQLITE_IOERR_CONVPATH error code is an extended error code for 
      SQLITE_IOERR used only by Cygwin VFS and indicating that the 
      cygwin_conv_path() system call failed. }
    SQLITE_IOERR_CONVPATH = Longint(libpassqlite.SQLITE_IOERR_CONVPATH),

    SQLITE_CODE_LAST = SQLITE_IOERR_CONVPATH
  {%H-});

implementation

end.

