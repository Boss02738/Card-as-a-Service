import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/views/widgets/arrow_fab.dart';
import 'package:flutter/services.dart'; 

class ActivatePhysical extends StatefulWidget {
  const ActivatePhysical({super.key});

  @override
  State<ActivatePhysical> createState() => _ActivatePhysicalState();
}

class _ActivatePhysicalState extends State<ActivatePhysical> {
  final dynamic args = Get.arguments;

  final List<TextEditingController> digitCtrls = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  final expiryCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();
  final ValueNotifier<bool> isFormValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    for (var ctrl in digitCtrls) {
      ctrl.addListener(_validateForm);
    }
    expiryCtrl.addListener(_validateForm);
    cvvCtrl.addListener(_validateForm);
  }

  void _validateForm() {
    String lastFour = digitCtrls.map((e) => e.text).join();
    // เช็คความยาว MM/YY (รวม / เป็น 5 ตัว) และ CVV 3 ตัว
    isFormValid.value =
        lastFour.length == 4 &&
        expiryCtrl.text.length == 5 &&
        cvvCtrl.text.length == 3;
  }

  void proceedToVerifyPin() {
    String inputLastFour = digitCtrls.map((e) => e.text).join();
    Get.toNamed(
      '/pin_verify_page',
      arguments: {
        'action': 'activate_physical_flow',
        'card': args['card'],
        'ownerName': args['ownerName'],
        'input_data': {
          'last_digits': inputLastFour,
          'expiry': expiryCtrl.text,
          'cvv': cvvCtrl.text,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dynamic card = args['card'];
    final String ownerName = args['ownerName'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'เปิดใช้งานบัตร',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.r),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildResponsiveHeader(card, ownerName),
            Padding(
              padding: EdgeInsets.all(25.r),
              child: Column(
                children: [
                  Text(
                    "กรอกข้อมูลบัตรเดบิต",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 25.h),
                  _buildFigmaInputRow(),
                  SizedBox(height: 35.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabelInput(
                          "วันหมดอายุ",
                          "MM/YY",
                          expiryCtrl,
                          5,
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: _buildLabelInput(
                          "CVV/CVC",
                          "ระบุเลข 3 หลัก",
                          cvvCtrl,
                          3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildResponsiveHeader(dynamic card, String ownerName) {
    // ✅ แก้ไข: โหลดรูปภาพจาก Base64
    final String? base64String = card['card_image'] ?? card['type_debit_image'];
    Uint8List? imageBytes;

    if (base64String != null && base64String.isNotEmpty) {
      try {
        imageBytes = base64Decode(base64String);
      } catch (e) {
        debugPrint("Error decoding base64: $e");
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 40.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B5BDB), Color(0xFF162E7A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.58,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                // ✅ แก้ไข: ใช้ MemoryImage แทน NetworkImage
                image: imageBytes != null
                    ? DecorationImage(
                        image: MemoryImage(imageBytes),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.white12,
              ),
              child: imageBytes == null 
                ? Icon(Icons.credit_card, size: 50.r, color: Colors.white24)
                : null,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            "NovaPay Debit Card",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "หมายเลข: **** **** **** ${card['last_digits'] ?? '****'}",
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaInputRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "XXXX - XXXX - XXXX - ",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
            Row(
              children: List.generate(
                4,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 32.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF264FAD),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextField(
                    controller: digitCtrls[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 3) {
                        focusNodes[index + 1].requestFocus();
                      }
                      if (val.isEmpty && index > 0) {
                        focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelInput(
    String label,
    String hint,
    TextEditingController ctrl,
    int max,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: max,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            if (label == "วันหมดอายุ") CardExpirationFormatter(),
          ],
          style: TextStyle(fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
            counterText: "",
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 10.w,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF264FAD),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(25.r),
        child: ValueListenableBuilder<bool>(
          valueListenable: isFormValid,
          builder: (context, isValid, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "ถัดไป",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: isValid ? Colors.black : Colors.grey,
                  ),
                ),
                SizedBox(width: 10.w),
                ArrowFab(
                  onPressed: isValid ? proceedToVerifyPin : () {},
                  enabled: isValid,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in digitCtrls) { c.dispose(); }
    for (var f in focusNodes) { f.dispose(); }
    expiryCtrl.dispose();
    cvvCtrl.dispose();
    isFormValid.dispose();
    super.dispose();
  }
}

class CardExpirationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newValueString = newValue.text;
    if (newValueString.length < oldValue.text.length) {
      return newValue;
    }
    String cleaned = newValueString.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = "";
    for (int i = 0; i < cleaned.length; i++) {
      formatted += cleaned[i];
      if (i == 1 && cleaned.length >= 2) {
        formatted += "/";
      }
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}