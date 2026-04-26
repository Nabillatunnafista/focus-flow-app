import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String hintText; // Tambah properti hint
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final VoidCallback? onToggleObscure;

  const CustomInput({
    super.key,
    required this.label,
    required this.hintText, // Wajib diisi
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.obscureText,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label di atas kotak
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(prefixIcon, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        
        TextFormField(
          controller: controller,
          obscureText: obscureText ?? false,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            hintText: hintText, // Menampilkan keterangan
            hintStyle: GoogleFonts.poppins(
              fontSize: 13, 
              color: AppColors.textGrey.withOpacity(0.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 0),
            ),
            
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),

            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (obscureText ?? true)
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textGrey,
                      size: 20,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}