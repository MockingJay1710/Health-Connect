import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class profile_list extends StatelessWidget {
  final String title;
  final String image;
  final Color color;
  final VoidCallback? onTap;

  const profile_list({
    Key? key,
    required this.title,
    required this.image,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 6.h,
              width: 90.w,
              child: Row(
                children: [
                  // Icon/Image Section
                  Container(
                    height: 6.h,
                    width: 15.w,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 247, 250, 247),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title Section
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Forward Icon
                  Container(
                    height: 6.h,
                    width: 10.w,
                    child: Image.asset(
                      "lib/icons/forward.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
