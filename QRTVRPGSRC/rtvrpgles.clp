/*--Program RTVRPGLES --Driver for Retrieve RPGLE source               */
/*    CPP for RTVRPGLES                                                */
/*    Created by Jim Friedman 01/26/04                                 */
 RTVRPGLES:  PGM        PARM(&PGMNAMLIB &SRCNAMLIB &MBRNAME)
             DCL        VAR(&PGMNAMLIB) TYPE(*CHAR) LEN(20)
             DCL        VAR(&SRCNAMLIB) TYPE(*CHAR) LEN(20)
             DCL        VAR(&OBJNAME) TYPE(*CHAR) LEN(10)
             DCL        VAR(&OBJLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SRCNAME) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SRCLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&MBRNAME) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PGMTYPE) TYPE(*CHAR) LEN(10)
             DCL        VAR(&NEWTEXT) TYPE(*CHAR) LEN(80)
             DCL        VAR(&ERROR) TYPE(*CHAR) LEN(1)

             CHGVAR     VAR(&OBJNAME) VALUE(%SST(&PGMNAMLIB 1 10))
             CHGVAR     VAR(&OBJLIB) VALUE(%SST(&PGMNAMLIB 11 10))
             CHGVAR     VAR(&SRCNAME) VALUE(%SST(&SRCNAMLIB 1 10))
             CHGVAR     VAR(&SRCLIB) VALUE(%SST(&SRCNAMLIB 11 10))
             IF         COND(&MBRNAME = '*PGM') THEN(CHGVAR +
                          VAR(&MBRNAME) VALUE(&OBJNAME))
             RTVOBJD    OBJ(&OBJLIB/&OBJNAME) OBJTYPE(*PGM) +
                          OBJATR(&PGMTYPE)
/*--Validate that requested object exists                              */
             MONMSG     MSGID(CPF9999) EXEC(DO)
                SNDPGMMSG  MSG('Requested program does not exist') +
                             MSGTYPE(*DIAG)
                GOTO       CMDLBL(ENDPGM)
             ENDDO
/*--Validate that requested object is RPGLE                            */
             IF         COND(&PGMTYPE ¬= 'RPGLE') THEN(DO)
                SNDPGMMSG  MSG('Requested program is not RPGLE') +
                             MSGTYPE(*DIAG)
                GOTO       CMDLBL(ENDPGM)
             ENDDO
             CHGVAR     VAR(&NEWTEXT) VALUE('Retrieved source for ' || +
                          &OBJLIB |< '/' || &OBJNAME)
/*--Add requested output source member                                 */
             ADDPFM     FILE(&SRCLIB/&SRCNAME) MBR(&MBRNAME) +
                          TEXT(&NEWTEXT) SRCTYPE(RPGLE)
             MONMSG     MSGID(CPF7306) EXEC(DO)
                SNDPGMMSG  MSG('Cannot add requested retrieval member') +
                             MSGTYPE(*DIAG)
                GOTO       CMDLBL(ENDPGM)
             ENDDO

             DMPOBJ     OBJ(&OBJLIB/&OBJNAME) OBJTYPE(*PGM)
             CRTDUPOBJ  OBJ(RTVWORK) FROMLIB(*LIBL) OBJTYPE(*FILE) +
                          TOLIB(QTEMP)
             MONMSG     MSGID(CPF2130) EXEC(CLRPFM FILE(RTVWORK))
            CPYSPLF    FILE(QPSRVDMP) TOFILE(QTEMP/RTVWORK) +
              SPLNBR(*LAST)
             DLTSPLF    FILE(QPSRVDMP) SPLNBR(*LAST)
             CRTSRCPF   FILE(QTEMP/QRPGLESRC) RCDLEN(112) MBR(*FILE) +
                          MAXMBRS(1)
             MONMSG     MSGID(CPF7302) EXEC(CLRPFM FILE(QTEMP/QRPGLESRC))
             OVRDBF     FILE(QRPGLESRC) TOFILE(QTEMP/QRPGLESRC) +
                          MBR(*FIRST)
             OVRDBF     FILE(RTVWORK) TOFILE(QTEMP/RTVWORK)
             CALL       PGM(RTVRPG) PARM(&ERROR)
             DLTOVR     FILE(QRPGLESRC)
             DLTOVR     FILE(RTVWORK)
             IF         COND(&ERROR ¬= 'Y') THEN(DO)
                CPYSRCF    FROMFILE(QTEMP/QRPGLESRC) +
                             TOFILE(&SRCLIB/&SRCNAME) FROMMBR(*FIRST) +
                             TOMBR(&MBRNAME) MBROPT(*ADD) SRCOPT(*SEQNBR)
             ENDDO
             ELSE       CMD(DO)
                RMVM       FILE(&SRCLIB/&SRCNAME) MBR(&MBRNAME)
                SNDPGMMSG  MSG('Requested program was not compiled with +
                             DBGVIEW(*LIST)') MSGTYPE(*DIAG)
             ENDDO
             CLRPFM     FILE(QTEMP/RTVWORK)
             CLRPFM     FILE(QTEMP/QRPGLESRC)

 ENDPGM:     ENDPGM
