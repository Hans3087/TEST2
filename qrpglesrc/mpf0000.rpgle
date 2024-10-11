     H DFTACTGRP(*NO) ACTGRP(*NEW)
     D Msg             S             50A
     D Msg1            S             50A
     D Msg2            S             50A

     c     *entry        plist
     c                   parm                    Msg
      /FREE
            Clear Msg1;
            Clear Msg2;
            Eval Msg = 'Hola';
            Eval Msg1 = Msg;
            Eval Msg  = Msg1;
      /END-FREE
     c*                  dsply                   Msg
     c*                  eval      *inlr = *on
     c                   return
