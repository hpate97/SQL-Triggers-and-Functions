import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.util.Scanner;

public class StockUser
{
    // code taken from https://dev.mysql.com/doc/connector-j/8.0/en/connector-j-usagenotes-connect-drivermanager.html
    // 
    public static void main(String[] args) {
        Connection conn = null;
        Statement stmt = null;

        CallableStatement callStmt = null;
        CallableStatement callStmt1 = null;
        CallableStatement callStmt2 = null;

        ResultSet rs = null;

        int numRows = -1;
        int Input = -1;
        int Input1 = -1;
        int Input2 = -1;

        double depAmount = 1.00;

        Scanner input = new Scanner(System.in);
        Scanner input1 = new Scanner(System.in);

        String accountName = "";

        boolean hadRS = true;

      try {
            conn =
                    DriverManager.getConnection(
                            "jdbc:mysql://localhost/StockMarket?" +
                            "user=student&password=password");

            // Do something with the Connection
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SHOW TABLES;");

            if (rs!=null){
                while(rs.next())
                {
                    System.out.println(rs.getString(1));

                }
            }

            System.out.print("What is the name of your account? ");
            accountName = input.nextLine();
            System.out.println();


            while(Input!=6)
            {
              System.out.print("Which operation would you like to perform (1-6)? ");
              Input = input.nextInt();
              System.out.println();
              switch(Input)
              {
                case 1: rs = stmt.executeQuery("SELECT Balance from Person WHERE AccountName =\"" + accountName + "\"");

                    if (rs!=null){
                        while(rs.next())
                        {
                            float balance = rs.getFloat(1);
                            System.out.println(balance);
                        }
                    }

                    break;

                case 2: rs = stmt.executeQuery("SELECT CompanyName, Quantity FROM Stock NATURAL JOIN Person NATURAL JOIN Company WHERE AccountName =\"" + accountName + "\"");

                System.out.println(accountName + " Owned Stocks:");

                if (rs!=null){
                        while(rs.next())
                        {
                            String compName = rs.getString(1);
                            int quantity = rs.getInt(2);
                            System.out.println(compName + "\t" + quantity);
                        }
                    }
                    break;

                case 3:
                    rs = stmt.executeQuery("SELECT LotID, CompanyID, CompanyName, Quantity, Price FROM SellOrder NATURAL JOIN Stock NATURAL JOIN Company NATURAL JOIN Person;");

                    System.out.println("LotID" + "\t" + "CompanyID" + "\t" + "CompanyName" + "\t" + "Quantity" + "\t" + "Price");

                    if (rs!=null)
                    {
                        while(rs.next())
                        {
                            int lotID = rs.getInt(1);
                            int compID = rs.getInt(4);
                            String compName = rs.getString(5);
                            int quantity = rs.getInt(6);
                            float price = rs.getFloat(7);

                            System.out.println(lotID + "\t" + compID + "\t" + compName + "\t" + quantity + "\t" + price);
                        }
										}

                            System.out.print("Enter LotID for Purchase: ");
                            Input1 = input.nextInt();
                            System.out.println();
                            System.out.print("How many:  ");
                            Input2 = input.nextInt();
                            System.out.println();

                            rs = stmt.executeQuery("SELECT CompanyName FROM SellOrder NATURAL JOIN Stock NATURAL JOIN Company NATURAL JOIN Person WHERE LotID =\"" + Input1 + "\"");
                            rs.next();
                            String compName = rs.getString("CompanyName");

                            callStmt = conn.prepareCall("{?=call BuyStock('" + accountName + "','" + compName + "', '" + Input2 + "')}");
                            callStmt.executeUpdate();
									
									if(rs!=null) 
									{
                          System.out.println("BuyStock Returned");
                          while(rs.next()) {
                            System.out.println(rs.getFloat(1));
                          }
                        }
                        break;
                case 4:

                    System.out.print("Enter Deposit Amount: ");
                    depAmount = input1.nextFloat();
                    System.out.println();
                    callStmt1 = conn.prepareCall("{call DepositFunds(?, ?)}");
                    callStmt1.setString("AccountName", accountName);
                    callStmt1.setDouble("amount", depAmount);

                    hadRS = callStmt1.execute();

                    while (hadRS)
                    {
                        rs = callStmt1.getResultSet();
                        while (rs.next()) {
                            float bal = rs.getFloat("Balance");
                            System.out.println("Success!!");

                        }
                        hadRS = callStmt1.getMoreResults();
                    }
                    break;

                case 5:

                    System.out.print("Enter Withdrawal Amount: ");
                    depAmount = input1.nextFloat();
                    System.out.println();
                    callStmt1 = conn.prepareCall("{call WithdrawFunds(?, ?)}");
                    callStmt1.setString("AccountName",accountName);
                    callStmt1.setDouble("amount",depAmount);

                    hadRS = callStmt1.execute();

                    while (hadRS)
                    {
                        rs = callStmt1.getResultSet();
                        while (rs.next()) {
                            float balance = rs.getFloat("Balance");

                            System.out.println("Success!!");
                        }
                        hadRS = callStmt1.getMoreResults();
                    }

                    break;
                case 6: 
									System.out.println("Goodbye."); 
									break;
              }
            }

        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
        }
        finally {
            // it is a good idea to release
            // resources in a finally{} block
            // in reverse-order of their creation
            // if they are no-longer needed

            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException sqlEx) {
                } // ignore

                rs = null;
            }

            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException sqlEx) {
                } // ignore

                stmt = null;
            }
        }
   }
}

