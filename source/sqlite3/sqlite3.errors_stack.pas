(******************************************************************************)
(*                                libPasSQLite                                *)
(*               object pascal wrapper around SQLite library                  *)
(*                                                                            *)
(* Copyright (c) 2020 - 2021                                Ivan Semenkov     *)
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
unit sqlite3.errors_stack;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  SysUtils, sqlite3.code, utils.errorsstack;

type
  { TSQLite3 database errors stack. }
  PSQL3LiteErrorsStack = ^TSQL3LiteErrorsStack;
  TSQL3LiteErrorsStack = class({$IFDEF FPC}specialize{$ENDIF}
    TListErrorsStack<String>)
  public
    { Add error to the stack. }
    procedure Push (AError : TSQLite3Code); overload;
    procedure Push (AErrorCode : Integer); overload;

    function GetEnumerator : {$IFNDEF FPC}TListErrorsStack<String>.{$ENDIF}
      TIterator;
  end;

implementation

{ TSQLite3ErrorsStack }

function TSQL3LiteErrorsStack.GetEnumerator :
  TSQL3LiteErrorsStack.TIterator;
begin
  Result := inherited GetEnumerator;
end;

procedure TSQL3LiteErrorsStack.Push (AErrorCode : Integer);
begin
  Push(TSQLite3Code(AErrorCode));
end;

procedure TSQL3LiteErrorsStack.Push (AError : TSQLite3Code);
begin
  case AError of
    SQLITE_OK : ;
    SQLITE_DONE : ;
    SQLITE_ROW : ;
    
    SQLITE_ERROR : Push('SQLITE_ERROR: SQLite3 database error.');
    SQLITE_INTERNAL : Push('SQLITE_INTERNAL: SQLite3 database internal '+
      'error.');
    SQLITE_PERM : Push('SQLITE_PERM: The requested access mode for a newly '+
      'created database could not be provided');
    SQLITE_ABORT : Push('SQLITE_ABORT: An operation was aborted prior to '+
      'completion.');
    SQLITE_BUSY : Push('SQLITE_BUSY: The database file could not be written '+
      '(or in some cases read) because of concurrent activity.');
    SQLITE_LOCKED : Push('SQLITE_LOCKED: A write operation could not continue '+
      'because of a conflict within the same database connection.');
    SQLITE_NOMEM : Push('SQLITE_NOMEM: SQLite was unable to allocate all the '+
      'memory it needed to complete the operation.');
    SQLITE_READONLY : Push('SQLITE_READONLY: Some data for the current '+
      'database connection does not have write permission.');
    SQLITE_INTERRUPT : Push('SQLITE_INTERRUPT: An operation was interrupted.');
    SQLITE_IOERR : Push('SQLITE_IOERR: The operation could not finish because '+
      'the operating system reported an I/O error.');
    SQLITE_CORRUPT : Push('SQLITE_CORRUPT: The database file has been '+
      'corrupted.');
    SQLITE_NOTFOUND : Push('SQLITE_NOTFOUND: SQLite3 database internally '+
      'error.');
    SQLITE_FULL : Push('SQLITE_FULL: A write could not complete because the '+
      'disk is full.');
    SQLITE_CANTOPEN : Push('SQLITE_CANTOPEN: SQLite was unable to open a '+
      'file.');
    SQLITE_PROTOCOL : Push('SQLITE_PROTOCOL: A problem with the file locking '+
      'protocol used by SQLite.');
    SQLITE_SCHEMA : Push('SQLITE_SCHEMA: The database schema has changed.');
    SQLITE_TOOBIG : Push('SQLITE_TOOBIG: A string or BLOB was too large.');
    SQLITE_CONSTRAINT : Push('SQLITE_CONSTRAINT: SQL constraint violation '+
      'occurred while trying to process an SQL statement.');
    SQLITE_MISMATCH : Push('SQLITE_MISMATCH: A datatype mismatch.');
    SQLITE_MISUSE : Push('SQLITE_MISUSE: The application uses any SQLite '+
      'interface in a way that is undefined or unsupported.');
    SQLITE_NOLFS : Push('SQLITE_NOLFS: System that do not support large files '+
      'when the database grows to be larger than what the filesystem can '+
      'handle.');
    SQLITE_AUTH : Push('SQLITE_AUTH: SQL statement being prepared is not '+
      'authorized.');
    SQLITE_RANGE : Push('SQLITE_RANGE: The parameter number argument to one '+
      'of the routines or the column number is out of range.');
    SQLITE_NOTADB : Push('SQLITE_NOTADB: The file being opened does not '+
      'appear to be an SQLite database file.');
    SQLITE_NOTICE : Push('SQLITE_NOTICE: An unusual operation is taking '+
      'place.');
    SQLITE_WARNING : Push('SQLITE_WARNING: An unusual and possibly '+
      'ill-advised operation is taking place.');
    SQLITE_OK_LOAD_PERMANENTLY : Push('SQLITE_OK_LOAD_PERMANENTLY: Extension '+
      'remains loaded into the process address space after the database '+
      'connection closes.');
    SQLITE_ERROR_MISSING_COLLSEQ : Push('SQLITE_ERROR_MISSING_COLLSEQ: SQL '+
      'statement could not be prepared because a collating sequence named in '+
      'that SQL statement could not be located.');
    SQLITE_BUSY_RECOVERY : Push('SQLITE_BUSY_RECOVERY: An operation could not '+
      'continue because another process is busy recovering a database file '+
      'following a crash.');
    SQLITE_LOCKED_SHAREDCACHE : Push('SQLITE_LOCKED_SHAREDCACHE: The locking '+
      'conflict has occurred due to contention.');
    SQLITE_READONLY_RECOVERY : Push('SQLITE_READONLY_RECOVERY: A database '+
      'cannot be opened because the database file needs to be recovered.');
    SQLITE_IOERR_READ : Push('SQLITE_IOERR_READ: A filesystem came unmounted '+
      'while the file was open.');
    SQLITE_CORRUPT_VTAB : Push('SQLITE_CORRUPT_VTAB: Content in the virtual '+
      'table is corrupt.');
    SQLITE_CONSTRAINT_CHECK : Push('SQLITE_CONSTRAINT_CHECK: A CHECK '+
      'constraint failed.');
    SQLITE_NOTICE_RECOVER_WAL : Push('SQLITE_NOTICE_RECOVER_WAL: A database '+
      'file is recovered.');
    SQLITE_WARNING_AUTOINDEX : Push('SQLITE_WARNING_AUTOINDEX: The database '+
      'might benefit from additional indexes.');
    SQLITE_ERROR_RETRY : Push('SQLITE_ERROR_RETRY: Try again to prepare a '+
      'statement that failed with an error on the previous attempt.');
    SQLITE_ABORT_ROLLBACK : Push('SQLITE_ABORT_ROLLBACK: SQL statement '+
      'aborted because the transaction that was active when the SQL statement '+
      'first started was rolled back.');
    SQLITE_BUSY_SNAPSHOT : Push('SQLITE_BUSY_SNAPSHOT: A database connection '+
      'tries to promote a read transaction into a write transaction');
    SQLITE_LOCKED_VTAB : Push('SQLITE_LOCKED_VTAB: Cannot complete the '+
      'current operation because of locks held by other threads or processes.');
    SQLITE_READONLY_CANTLOCK : Push('SQLITE_READONLY_CANTLOCK: SQLite is '+
      'unable to obtain a read lock.');
    SQLITE_IOERR_SHORT_READ : Push('SQLITE_IOERR_SHORT_READ: A read attempt '+
      'in the VFS layer was unable to obtain as many bytes as was requested.');
    SQLITE_CORRUPT_SEQUENCE : Push('SQLITE_CORRUPT_SEQUENCE: The schema of '+
      'the sqlite_sequence table is corrupt.');
    SQLITE_CANTOPEN_ISDIR : Push('SQLITE_CANTOPEN_ISDIR: A file open ' +
      'operation failed because the file is really a directory.');
    SQLITE_CONSTRAINT_COMMITHOOK : Push('SQLITE_CONSTRAINT_COMMITHOOK: ' +
      'A commit hook callback returned non-zero that thus caused the SQL ' +
      'statement to be rolled back.');
    SQLITE_NOTICE_RECOVER_ROLLBACK : Push('SQLITE_NOTICE_RECOVER_ROLLBACK: ' +
      'A hot journal is rolled back.');
    SQLITE_ERROR_SNAPSHOT : Push('SQLITE_ERROR_SNAPSHOT: ' +
      'Attempting to start a read transaction on an historical version of ' +
      'the database. The historical snapshot is no longer available.');
    SQLITE_READONLY_ROLLBACK : Push('SQLITE_READONLY_ROLLBACK: ' +
      'A database cannot be opened because it has a hot journal that needs ' +
      'to be rolled back but cannot because the database is readonly.');
    SQLITE_IOERR_WRITE : Push('SQLITE_IOERR_WRITE: An I/O error in the VFS ' +
      'layer while trying to write into a file on disk.');
    SQLITE_CANTOPEN_FULLPATH : Push('SQLITE_CANTOPEN_FULLPATH: ' +
      'A file open operation failed because the operating system was unable ' +
      'to convert the filename into a full pathname.');
    SQLITE_CONSTRAINT_FOREIGNKEY : Push('SQLITE_CONSTRAINT_FOREIGNKEY:' +
      'A foreign key constraint failed.');
    SQLITE_READONLY_DBMOVED : Push('SQLITE_READONLY_DBMOVED: ' + 
      'A database cannot be modified because the database file has been ' +
      'moved since it was opened, and so any attempt to modify the database ' +
      'might result in database corruption.');
    SQLITE_IOERR_FSYNC : Push('SQLITE_IOERR_FSYNC: An I/O error in the VFS ' +
      'layer while trying to flush previously written content out of OS ' +
      'and/or disk-control buffers and into persistent storage.');
    SQLITE_CANTOPEN_CONVPATH : Push('SQLITE_CANTOPEN_CONVPATH: ' +
      'The cygwin_conv_path() system call failed while trying to open a file.');
    SQLITE_READONLY_CANTINIT : Push('SQLITE_READONLY_CANTINIT : The shared ' +
      'memory region used by WAL mode exists buts its content is unreliable ' +
      'and unusable by the current process since the current process does ' +
      'not have write permission on the shared memory region.');
    SQLITE_IOERR_DIR_FSYNC : Push('SQLITE_IOERR_DIR_FSYNC: An I/O error in ' +
      'the VFS layer while trying to invoke fsync() on a directory.');
    SQLITE_CONSTRAINT_NOTNULL : Push('SQLITE_CONSTRAINT_NOTNULL :' +
      'A NOT NULL constraint failed.');
    SQLITE_READONLY_DIRECTORY : Push('SQLITE_READONLY_DIRECTORY: the database '+
      'is read-only because process does not have permission to create a '+
      'journal file in the same directory as the database.');
    SQLITE_IOERR_TRUNCATE : Push('SQLITE_IOERR_TRUNCATE : An I/O error in the '+
      'VFS layer while trying to truncate a file to a smaller size.');
    SQLITE_CONSTRAINT_PRIMARYKEY : Push('SQLITE_CONSTRAINT_PRIMARYKEY : ' +
      'A PRIMARY KEY constraint failed.');
    SQLITE_IOERR_FSTAT : Push('SQLITE_IOERR_FSTAT : An I/O error in the VFS '+
      'layer while trying to invoke fstat() (or the equivalent) on a file in '+
      'order to determine information such as the file size or access '+
      'permissions.');
    SQLITE_CONSTRAINT_TRIGGER : Push('SQLITE_CONSTRAINT_TRIGGER : A RAISE '+
      'function within a trigger fired, causing the SQL statement to abort.');
    SQLITE_IOERR_UNLOCK : Push('SQLITE_IOERR_UNLOCK : An I/O error within '+
      'xUnlock method on the sqlite3_io_methods object.');
    SQLITE_CONSTRAINT_UNIQUE : Push('SQLITE_CONSTRAINT_UNIQUE : A UNIQUE '+
      'constraint failed.');
    SQLITE_IOERR_RDLOCK : Push('SQLITE_IOERR_RDLOCK : An I/O error within '+
      'xLock method on the sqlite3_io_methods object while trying to obtain a '+
      'read lock.');
    SQLITE_CONSTRAINT_VTAB : Push('SQLITE_CONSTRAINT_VTAB : '+
      'application-defined error code.');
    SQLITE_IOERR_DELETE : Push('SQLITE_IOERR_DELETE : An I/O error within '+
      'xDelete method on the sqlite3_vfs object.');
    SQLITE_CONSTRAINT_ROWID : Push('SQLITE_CONSTRAINT_ROWID : ' +
      'A rowid is not unique.');
    SQLITE_IOERR_NOMEM : Push('SQLITE_IOERR_NOMEM : An operation could not be '+
      'completed due to the inability to allocate sufficient memory.');
    SQLITE_IOERR_ACCESS : Push('SQLITE_IOERR_ACCESS : An I/O error within the '+
      'xAccess method on the sqlite3_vfs object.');
    SQLITE_IOERR_CHECKRESERVEDLOCK : Push('SQLITE_IOERR_CHECKRESERVEDLOCK : '+
      'An I/O error within the xCheckReservedLock method on the '+
      'sqlite3_io_methods object.');
    SQLITE_IOERR_LOCK : Push('SQLITE_IOERR_LOCK : An I/O error in the '+
      'advisory file locking logic.');
    SQLITE_IOERR_CLOSE : Push('SQLITE_IOERR_CLOSE : An I/O error within the '+
      'xClose method on the sqlite3_io_methods object.');
    SQLITE_IOERR_SHMOPEN : Push('SQLITE_IOERR_SHMOPEN : An I/O error within '+
      'the xShmMap method on the sqlite3_io_methods object while trying to '+
      'open a new shared memory segment.');
    SQLITE_IOERR_SHMSIZE : Push('SQLITE_IOERR_SHMSIZE : An I/O error within '+
      'the xShmMap method on the sqlite3_io_methods object while trying to '+
      'enlarge a "shm" file as part of WAL mode transaction processing.');
    SQLITE_IOERR_SHMMAP : Push('SQLITE_IOERR_SHMMAP : An I/O error within the '+
      'xShmMap method on the sqlite3_io_methods object while trying to map a '+
      'shared memory segment into the process address space.');
    SQLITE_IOERR_SEEK : Push('SQLITE_IOERR_SEEK : An I/O error within the '+
      'xRead or xWrite methods on the sqlite3_io_methods object while trying '+
      'to seek a file descriptor to the beginning point of the file where the '+
      'read or write is to occur.');
    SQLITE_IOERR_DELETE_NOENT : Push('SQLITE_IOERR_DELETE_NOENT : The xDelete '+
      'method on the sqlite3_vfs object failed because the file being deleted '+
      'does not exist.');
    SQLITE_IOERR_MMAP : Push('SQLITE_IOERR_MMAP : An I/O error within the '+
      'xFetch or xUnfetch methods on the sqlite3_io_methods object while '+
      'trying to map or unmap part of the database file into the process '+
      'address space.');
    SQLITE_IOERR_GETTEMPPATH : Push('SQLITE_IOERR_GETTEMPPATH : The VFS is '+
      'unable to determine a suitable directory in which to place temporary '+
      'files.');
    SQLITE_IOERR_CONVPATH : Push('SQLITE_IOERR_CONVPATH : The '+
      'cygwin_conv_path() system call failed.')
  else
    Push(IntToStr(Integer(AError)) + 
      ': Undefined SQLite3 database error code.');
  end;  
end;

end.
