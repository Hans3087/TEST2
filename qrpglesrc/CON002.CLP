     /*      DLYJOB     DLY(48)     */
             PGM
             DCL        VAR(&DIRE) TYPE(*CHAR)
             CHGVAR     VAR(&DIRE) VALUE('www.google.cl')
             CALL       PGM(CON001) PARM(&DIRE)
             SNDPGMMSG  MSG('LA IP ES' CAT &DIRE)
             RETURN
             ENDPGM
