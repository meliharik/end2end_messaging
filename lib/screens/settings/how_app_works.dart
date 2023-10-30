import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:end2end_messaging/helpers/space.dart';
import 'package:end2end_messaging/models/user.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class HowAppWorkScreen extends ConsumerStatefulWidget {
  final FirestoreUser user;
  const HowAppWorkScreen({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HowAppWorkScreenState();
}

class _HowAppWorkScreenState extends ConsumerState<HowAppWorkScreen> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CustomColors.black,
        border: Border(
          bottom: BorderSide(
            color: CustomColors.grey,
            width: 0.0,
          ),
        ),
        middle: const Text(
          'How Securely works',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      backgroundColor: CustomColors.black,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SpaceHelper.boslukWidth(context, 0.03),
                  Text(
                    'A World with',
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SpaceHelper.boslukWidth(context, 0.02),
                  AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      RotateAnimatedText(
                        'Keys',
                        textStyle: GoogleFonts.poppins(
                          fontSize: MediaQuery.of(context).size.width * 0.09,
                          fontWeight: FontWeight.w600,
                          color: CustomColors.primaryColor,
                        ),
                      ),
                      RotateAnimatedText(
                        'Secrets',
                        textStyle: GoogleFonts.poppins(
                          fontSize: MediaQuery.of(context).size.width * 0.09,
                          fontWeight: FontWeight.w600,
                          color: CustomColors.primaryColor,
                        ),
                      ),
                      RotateAnimatedText(
                        'Messages',
                        textStyle: GoogleFonts.poppins(
                          fontSize: MediaQuery.of(context).size.width * 0.09,
                          fontWeight: FontWeight.w600,
                          color: CustomColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                'We are using end-to-end encryption. This means that your messages are encrypted and decrypted only on your device. We do not have access to your messages.',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.03),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                'Do not have access? Where are my messages?',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.055,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                'We are using RSA algorithm to encrypt your messages. This algorithm is one of the most secure algorithms in the world.',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                'RSA (Rivest-Shamir-Adleman) encryption algorithm is a commonly used public-key encryption method. Its operation is as follows:',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                '1- Key Pair Generation',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                '''- The first step is the creation of two keys: the public key and the private key.\n
- The public key can be known by everyone and is used to encrypt data.\n
- The private key is known only to the owner and is used to decrypt the encrypted data.''',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                '2- Key Generation',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                '''- First, two large prime numbers (p and q) are selected.
These prime numbers are used to calculate n = p * q. n is often referred to as the RSA modulus.\n
- A φ(n) function is calculated. φ(n) = (p-1) * (q-1).\n
- Then, a public key (e, n) is selected, where e is an integer between 1 and φ(n), and they are coprime.\n
- The private key (d, n) is calculated, where d satisfies the condition (e * d) % φ(n) = 1.''',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                '3- Encryption',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                '''- The person who wants to encrypt the data uses the recipient's public key (e, n).\n
- The message M representing the data must satisfy the condition 0 < M < n.\n
- Message M is transformed into the encrypted message C: C ≡ M^e (mod n).''',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                '4- Decryption of the Encrypted Message:',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                '''- The encrypted message can be decrypted using the recipient's private key (d, n).\n
- The encrypted message C is transformed back into the original message M: M ≡ C^d (mod n).''',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                'Your private key is stored in your device. We do not have access to your private key. If you delete your private key, you will not be able to decrypt your messages.',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.03),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                'A scenario...',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.055,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                "The scenario works as follows: Your message is encrypted with the recipient's public key. Then, you send this message to the database. The message in the database can only be decrypted with the recipient's private key.",
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                "For example, user's public key is this: MIIBCgKCAQEA6YleQ7l5mbzni5CylV5sv0oWSpOOY5nLH... And the private key is this: XK4fYw4KUVF8TFTrYtlCopQNN1husaEqWw7FMNVqDd0ULI...",
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                "If you want to send a message to this user, the only thing that stores in the database is this:",
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Center(
              child: Text(
                "0x1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q...",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  
                  fontStyle: FontStyle.italic,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Text(
                "If the user decryptes this message, the message they will see is this:",
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.02),
            Center(
              child: Text(
                "Hi!",
                style: GoogleFonts.poppins(
                  
                  fontStyle: FontStyle.italic,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceHelper.boslukHeight(context, 0.2),
          ],
        ),
      ),
    );
  }
}
