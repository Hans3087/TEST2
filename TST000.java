import java.beans.PropertyVetoException;
import java.io.IOException;




/**
 * Test program to test the RPG call from Java.
 */
public class TST000 {

	//AS400 RPG progam path
	String fullProgramName = "/QSYS.LIB/PBFORM12.LIB/PBFORM12CL.PGM";
	try {
	    // Create an AS400 object
	    as400 = new AS400(HOST, UID, PWD);

	    // Create a parameter list
	    // The list must have both input and output parameters
	    parmList = new ProgramParameter[2];

	    // Convert the Strings to IBM format
	    AS400Text nametext1 = new AS400Text(2);
	    AS400Text nametext2 = new AS400Text(200);

	    // Create the input parameter // get the exact patameter type and length, if not this not be working  
	    
	    parmList[0] = new ProgramParameter(nametext1.toBytes("1"),2);
	    parmList[1] = new ProgramParameter(nametext2.toBytes("Ravinath Fernando"),200);
	    // Create the output parameter
	    AS400 as400 = null;
		ProgramParameter[] parmList;//parameter list witch is accepting AS400 RPG program
		ProgramCall programCall;
	    programCall = new ProgramCall(as400);
	    programCall.setProgram(fullProgramName, parmList);

	    if (!programCall.run()) {
	        /**
	         * If the AS/400 is not run then look at the message list to
	         * find out why it didn't run.
	         */
	        AS400Message[] messageList = programCall.getMessageList();
	        for (AS400Message message : messageList) {
	            System.out.println(message.getID() + " - " + message.getText());
	        }
	    } else {
	        System.out.println("success");
	        /**
	         * Else the program is successfull. Process the output, which
	         * contains the returned data.
	         */
	        //use same parameter type which will be return from AS400 program
	        AS400Text text1 = new AS400Text(2);
	        System.out.println(text1.toObject(parmList[0].getOutputData()));
	        AS400Text text2 = new AS400Text(200);
	        System.out.println(text2.toObject(parmList[1].getOutputData()));
	    }
	    as400.disconnectService(AS400.COMMAND);
	    //-----------------------
	} catch (Exception e) {
	    e.printStackTrace();
	    System.err.println(":: Exception ::" + e.toString());
	} finally {
	    try {
	        // Make sure to disconnect 
	        if (as400 != null) {
	            as400.disconnectAllServices();
	        }
	    } catch (Exception e) {
	        System.err.println(":: Exception ::" + e.toString());
	    }
	}
	}
}
