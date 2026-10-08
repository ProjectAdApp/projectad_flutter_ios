import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:projectad/env.dart';
import 'package:projectad/service/language/AppLocalizations.dart';
import 'package:projectad/service/product.dart';

class MailS{
  Future<int> sendo(BuildContext context, Product p) async {


    
  String username = Env.smtpUsername;
  String password = Env.smtpPassword;

  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.  
  
  // Create our message.
  final message = Message()
    ..from = Address(username, 'ProjectAd')
    
    ..recipients.add(FirebaseAuth.instance.currentUser.email)
    ..subject = AppLocalizations.of(context).translateKey("s150_")
    ..html = getHTML( p.title,Localizations.localeOf(context).languageCode,);

  

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
    
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
    
  }

  return 0;
  // DONE
  
  
  // Let's send another message using a slightly different syntax:
  //
  // Addresses without a name part can be set directly.
  // For instance `..recipients.add('destination@example.com')`
  // If you want to display a name part you have to create an
  // Address object: `new Address('destination@example.com', 'Display name part')`
  // Creating and adding an Address object without a name part
  // `new Address('destination@example.com')` is equivalent to
  // adding the mail address as `String`.

    
  
  // Sending multiple messages with the same connection
  //
  // Create a smtp client that will persist the connection
  /*var connection = PersistentConnection(smtpServer);
  
  // Send the first message
  await connection.send(message);
  
  // send the equivalent message    
  // close the connection
  await connection.close();*/
  
}
Future<int>sends(String subj, String body) async {
  String username = Env.smtpUsername;
  String password = Env.smtpPassword;


  print("hello?");

  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.  
  
  // Create our message.
  final message = Message()
    ..from = Address(username, 'PaymentCenter')
    ..recipients.add(Env.adminEmail)
    ..subject = subj
    ..text=body;

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
    
    return 1;
  } on MailerException catch (e) {
    print('Message not sent.');
    Fluttertoast.showToast(msg: "message not send, make a screenshot!", toastLength: Toast.LENGTH_SHORT);
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
    

  }

  return 0;
  // DONE
  
  
  // Let's send another message using a slightly different syntax:
  //
  // Addresses without a name part can be set directly.
  // For instance `..recipients.add('destination@example.com')`
  // If you want to display a name part you have to create an
  // Address object: `new Address('destination@example.com', 'Display name part')`
  // Creating and adding an Address object without a name part
  // `new Address('destination@example.com')` is equivalent to
  // adding the mail address as `String`.

    
  
  // Sending multiple messages with the same connection
  //
  // Create a smtp client that will persist the connection
  
  
}
 String getHTML(String s, String lang) {
            List<String> m = new List(4);
            if (lang==("de")) {
                m[0] = "Glückwunsch zu deinem Kauf von";
                m[1] = "Danke, dass du diesen Artikel gekauft hast. Wir werden dir den Artikel so schnell wie möglich zusenden. Viel Spaß!";
                m[2] = "Dein ProjectAd Team ";
                m[3] = "ProjectAd - Alle Rechte vorbehalten";
            } else {
                m[0] = "Congrats you bought a ";
                m[1] = "Thanks for buying this offer. We will send you the product as soon as possible. Have fun!";
                m[2] = "Dein ProjectAd Team ";
                m[3] = "ProjectAd - All rights reserved";
            }
            return "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional //EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n" +
                    "\n" +
                    "<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:v=\"urn:schemas-microsoft-com:vml\">\n" +
                    "<head>\n" +
                    "\n" +
                    "<meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"/>\n" +
                    "<meta content=\"width=device-width\" name=\"viewport\"/>\n" +
                    "\n" +
                    "<meta content=\"IE=edge\" http-equiv=\"X-UA-Compatible\"/>\n" +
                    "\n" +
                    "<title></title>\n" +
                    "\n" +
                    "<link href=\"https://fonts.googleapis.com/css?family=Lato\" rel=\"stylesheet\" type=\"text/css\"/>\n" +
                    "\n" +
                    "<style type=\"text/css\">\n" +
                    "body {\n" +
                    "margin: 0;\n" +
                    "padding: 0;\n" +
                    "}\n" +
                    "\n" +
                    "table,\n" +
                    "td,\n" +
                    "tr {\n" +
                    "vertical-align: top;\n" +
                    "border-collapse: collapse;\n" +
                    "}\n" +
                    "\n" +
                    "* {\n" +
                    "line-height: inherit;\n" +
                    "}\n" +
                    "\n" +
                    "a[x-apple-data-detectors=true] {\n" +
                    "color: inherit !important;\n" +
                    "text-decoration: none !important;\n" +
                    "}\n" +
                    "</style>\n" +
                    "<style id=\"media-query\" type=\"text/css\">\n" +
                    "@media (max-width: 670px) {\n" +
                    "\n" +
                    ".block-grid,\n" +
                    ".col {\n" +
                    "min-width: 320px !important;\n" +
                    "max-width: 100% !important;\n" +
                    "display: block !important;\n" +
                    "}\n" +
                    "\n" +
                    ".block-grid {\n" +
                    "width: 100% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".col {\n" +
                    "width: 100% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".col>div {\n" +
                    "margin: 0 auto;\n" +
                    "}\n" +
                    "\n" +
                    "img.fullwidth,\n" +
                    "img.fullwidthOnMobile {\n" +
                    "max-width: 100% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".no-stack .col {\n" +
                    "min-width: 0 !important;\n" +
                    "display: table-cell !important;\n" +
                    "}\n" +
                    "\n" +
                    ".no-stack.two-up .col {\n" +
                    "width: 50% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".no-stack .col.num4 {\n" +
                    "width: 33% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".no-stack .col.num8 {\n" +
                    "width: 66% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".no-stack .col.num4 {\n" +
                    "width: 33% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".no-stack .col.num3 {\n" +
                    "width: 25% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".no-stack .col.num6 {\n" +
                    "width: 50% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".no-stack .col.num9 {\n" +
                    "width: 75% !important;\n" +
                    "}\n" +
                    "\n" +
                    ".video-block {\n" +
                    "max-width: none !important;\n" +
                    "}\n" +
                    "\n" +
                    ".mobile_hide {\n" +
                    "min-height: 0px;\n" +
                    "max-height: 0px;\n" +
                    "max-width: 0px;\n" +
                    "display: none;\n" +
                    "overflow: hidden;\n" +
                    "font-size: 0px;\n" +
                    "}\n" +
                    "\n" +
                    ".desktop_hide {\n" +
                    "display: block !important;\n" +
                    "max-height: none !important;\n" +
                    "}\n" +
                    "}\n" +
                    "</style>\n" +
                    "</head>\n" +
                    "<body class=\"clean-body\" style=\"margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #F5F5F5;\">\n" +
                    "<table bgcolor=\"#F5F5F5\" cellpadding=\"0\" cellspacing=\"0\" class=\"nl-container\" role=\"presentation\" style=\"table-layout: fixed; vertical-align: top; min-width: 320px; Margin: 0 auto; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #F5F5F5; width: 100%;\" valign=\"top\" width=\"100%\">\n" +
                    "<tbody>\n" +
                    "<tr style=\"vertical-align: top;\" valign=\"top\">\n" +
                    "<td style=\"word-break: break-word; vertical-align: top;\" valign=\"top\">\n" +
                    "<div style=\"background-color:transparent;\">\n" +
                    "<div class=\"block-grid\" style=\"Margin: 0 auto; min-width: 320px; max-width: 650px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: transparent;\">\n" +
                    "<div style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n" +
                    "<div class=\"col num12\" style=\"min-width: 320px; max-width: 650px; display: table-cell; vertical-align: top; width: 650px;\">\n" +
                    "<div style=\"width:100% !important;\">\n" +
                    "<div style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;\">\n" +
                    "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"divider\" role=\"presentation\" style=\"table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;\" valign=\"top\" width=\"100%\">\n" +
                    "<tbody>\n" +
                    "<tr style=\"vertical-align: top;\" valign=\"top\">\n" +
                    "<td class=\"divider_inner\" style=\"word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;\" valign=\"top\">\n" +
                    "<table align=\"center\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"divider_content\" height=\"10\" role=\"presentation\" style=\"table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 0px solid transparent; height: 10px; width: 100%;\" valign=\"top\" width=\"100%\">\n" +
                    "<tbody>\n" +
                    "<tr style=\"vertical-align: top;\" valign=\"top\">\n" +
                    "<td height=\"10\" style=\"word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;\" valign=\"top\"><span></span></td>\n" +
                    "</tr>\n" +
                    "</tbody>\n" +
                    "</table>\n" +
                    "</td>\n" +
                    "</tr>\n" +
                    "</tbody>\n" +
                    "</table>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "<div style=\"background-color:transparent;\">\n" +
                    "<div class=\"block-grid two-up no-stack\" style=\"Margin: 0 auto; min-width: 320px; max-width: 650px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: #FFFFFF;\">\n" +
                    "<div style=\"border-collapse: collapse;display: table;width: 100%;background-color:#FFFFFF;\">\n" +
                    "<div class=\"col num6\" style=\"min-width: 320px; max-width: 325px; display: table-cell; vertical-align: top; width: 325px;\">\n" +
                    "<div style=\"width:100% !important;\">\n" +
                    "<div style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:25px; padding-bottom:25px; padding-right: 0px; padding-left: 25px;\">\n" +
                    "<div style=\"color:#555555;font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n" +
                    "<p style=\"font-size: 12px; line-height: 1.2; color: #555555; font-family: 'Lato', Tahoma, Verdana, Segoe, sans-serif; mso-line-height-alt: 14px; margin: 0;\"><em><span style=\"font-size: 30px;\"><strong>ProjectAd</strong></span></em></p>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "<div class=\"col num6\" style=\"min-width: 320px; max-width: 325px; display: table-cell; vertical-align: top; width: 325px;\">\n" +
                    "<div style=\"width:100% !important;\">\n" +
                    "<div style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:25px; padding-bottom:25px; padding-right: 25px; padding-left: 0px;\">\n" +
                    "<div></div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "<div style=\"background-color:transparent;\">\n" +
                    "<div class=\"block-grid\" style=\"Margin: 0 auto; min-width: 320px; max-width: 650px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: #D6E7F0;\">\n" +
                    "<div style=\"border-collapse: collapse;display: table;width: 100%;background-color:#D6E7F0;\">\n" +
                    "<div class=\"col num12\" style=\"min-width: 320px; max-width: 650px; display: table-cell; vertical-align: top; width: 650px;\">\n" +
                    "<div style=\"width:100% !important;\">\n" +
                    "<div style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:60px; padding-right: 25px; padding-left: 25px;\">\n" +
                    "<div align=\"center\" class=\"img-container center fixedwidth\" style=\"padding-right: 0px;padding-left: 0px;\">\n" +
                    "<div style=\"font-size:1px;line-height:45px\"> </div><img align=\"center\" alt=\"Image\" border=\"0\" class=\"center fixedwidth\" src=\"cid:gam\" style=\"text-decoration: none; -ms-interpolation-mode: bicubic; border: 0; height: auto; width: 100%; max-width: 540px; display: block;\" title=\"Image\" width=\"540\"/>\n" +
                    "</div>\n" +
                    "<div style=\"color:#052d3d;font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif;line-height:1.5;padding-top:20px;padding-right:10px;padding-bottom:0px;padding-left:15px;\">\n" +
                    "<div style=\"line-height: 1.5; font-family: 'Lato', Tahoma, Verdana, Segoe, sans-serif; font-size: 12px; color: #052d3d; mso-line-height-alt: 18px;\">\n" +
                    "<p style=\"line-height: 1.5; text-align: center; font-size: 38px; mso-line-height-alt: 57px; margin: 0;\"><span style=\"font-size: 38px;\"><strong>" + m[0] + "</strong></span></p>\n" +
                    "<p style=\"font-size: 34px; line-height: 1.5; text-align: center; mso-line-height-alt: 51px; margin: 0;\"><span style=\"font-size: 34px;\"><strong><span style=\"font-size: 34px;\"><span style=\"color: #2190e3; font-size: 34px;\">" + s + "</span></span></strong></span></p>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "<div style=\"color:#555555;font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n" +
                    "<div style=\"line-height: 1.2; font-family: 'Lato', Tahoma, Verdana, Segoe, sans-serif; font-size: 12px; color: #555555; mso-line-height-alt: 14px;\">\n" +
                    "<p style=\"line-height: 1.2; text-align: center; font-size: 12px; mso-line-height-alt: 14px; margin: 0;\"><span style=\"color: #000000;\"><span style=\"font-size: 18px;\">" + m[1] + "</span></span></p>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "<div align=\"center\" class=\"button-container\" style=\"padding-top:20px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n" +
                    "<a href=\"projectad.de\" style=\"-webkit-text-size-adjust: none; text-decoration: none; display: inline-block; color: #ffffff; background-color: #fc7318; border-radius: 15px; -webkit-border-radius: 15px; -moz-border-radius: 15px; width: auto; width: auto; border-top: 1px solid #fc7318; border-right: 1px solid #fc7318; border-bottom: 1px solid #fc7318; border-left: 1px solid #fc7318; padding-top: 10px; padding-bottom: 10px; font-family: 'Lato', Tahoma, Verdana, Segoe, sans-serif; text-align: center; mso-border-alt: none; word-break: keep-all;\" target=\"_blank\"><span style=\"padding-left:40px;padding-right:40px;font-size:16px;display:inline-block;\">\n" +
                    "<span style=\"font-size: 16px; line-height: 2; mso-line-height-alt: 32px;\"><strong>" + m[2] + "</strong></span>\n" +
                    "</span></a>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "<div style=\"background-color:transparent;\">\n" +
                    "<div class=\"block-grid\" style=\"Margin: 0 auto; min-width: 320px; max-width: 650px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: transparent;\">\n" +
                    "<div style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n" +
                    "<div class=\"col num12\" style=\"min-width: 320px; max-width: 650px; display: table-cell; vertical-align: top; width: 650px;\">\n" +
                    "<div style=\"width:100% !important;\">\n" +
                    "<div style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:20px; padding-bottom:60px; padding-right: 0px; padding-left: 0px;\">\n" +
                    "<table cellpadding=\"0\" cellspacing=\"0\" class=\"social_icons\" role=\"presentation\" style=\"table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\" valign=\"top\" width=\"100%\">\n" +
                    "<tbody>\n" +
                    "<tr style=\"vertical-align: top;\" valign=\"top\">\n" +
                    "<td style=\"word-break: break-word; vertical-align: top; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;\" valign=\"top\">\n" +
                    "<table activate=\"activate\" align=\"center\" alignment=\"alignment\" cellpadding=\"0\" cellspacing=\"0\" class=\"social_table\" role=\"presentation\" style=\"table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: undefined; mso-table-tspace: 0; mso-table-rspace: 0; mso-table-bspace: 0; mso-table-lspace: 0;\" to=\"to\" valign=\"top\">\n" +
                    "<tbody>\n" +
                    "<tr align=\"center\" style=\"vertical-align: top; display: inline-block; text-align: center;\" valign=\"top\">\n" +
                    "<td style=\"word-break: break-word; vertical-align: top; padding-bottom: 5px; padding-right: 8px; padding-left: 8px;\" valign=\"top\"><a href=\"https://www.facebook.com/officialprojectad/\" target=\"_blank\"><img alt=\"Facebook\" height=\"32\" src=\"\" style=\"text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: none; display: block;\" title=\"Facebook\" width=\"32\"/></a></td>\n" +
                    "<td style=\"word-break: break-word; vertical-align: top; padding-bottom: 5px; padding-right: 8px; padding-left: 8px;\" valign=\"top\"><a href=\"https://twitter.com/dofficial_a\" target=\"_blank\"><img alt=\"Twitter\" height=\"32\" src=\"cid:mag\" style=\"text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: none; display: block;\" title=\"Twitter\" width=\"32\"/></a></td>\n" +
                    "<td style=\"word-break: break-word; vertical-align: top; padding-bottom: 5px; padding-right: 8px; padding-left: 8px;\" valign=\"top\"><a href=\"https://www.instagram.com/officialprojectad/\" target=\"_blank\"><img alt=\"Instagram\" height=\"32\" src=\"cid:amg\" style=\"text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: none; display: block;\" title=\"Instagram\" width=\"32\"/></a></td>\n" +
                    "</tr>\n" +
                    "</tbody>\n" +
                    "</table>\n" +
                    "</td>\n" +
                    "</tr>\n" +
                    "</tbody>\n" +
                    "</table>\n" +
                    "<div style=\"color:#555555;font-family:'Lato', Tahoma, Verdana, Segoe, sans-serif;line-height:1.5;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n" +
                    "<p style=\"font-size: 12px; line-height: 1.5; text-align: center; color: #555555; font-family: 'Lato', Tahoma, Verdana, Segoe, sans-serif; mso-line-height-alt: 18px; margin: 0;\">" + m[3] + "</p>\n" +
                    "</div>\n" +
                    "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"divider\" role=\"presentation\" style=\"table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;\" valign=\"top\" width=\"100%\">\n" +
                    "<tbody>\n" +
                    "<tr style=\"vertical-align: top;\" valign=\"top\">\n" +
                    "<td class=\"divider_inner\" style=\"word-break: break-word; vertical-align: top; min-width: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px;\" valign=\"top\">\n" +
                    "<table align=\"center\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"divider_content\" height=\"0\" role=\"presentation\" style=\"table-layout: fixed; vertical-align: top; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-top: 1px dotted #C4C4C4; height: 0px; width: 60%;\" valign=\"top\" width=\"60%\">\n" +
                    "<tbody>\n" +
                    "<tr style=\"vertical-align: top;\" valign=\"top\">\n" +
                    "<td height=\"0\" style=\"word-break: break-word; vertical-align: top; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;\" valign=\"top\"><span></span></td>\n" +
                    "</tr>\n" +
                    "</tbody>\n" +
                    "</table>\n" +
                    "</td>\n" +
                    "</tr>\n" +
                    "</tbody>\n" +
                    "</table>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</div>\n" +
                    "</td>\n" +
                    "</tr>\n" +
                    "</tbody>\n" +
                    "</table>\n" +
                    "</body>\n" +
                    "</html>";
        }
}