import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_app/module/controller/card_detail_controller.dart';
import 'package:my_app/module/controller/home_controller.dart';
import 'package:my_app/module/controller/status_card_controller.dart';
import 'package:my_app/views/widgets/debitcard.dart';

class MyCardDetail extends StatefulWidget {
  const MyCardDetail({super.key});

  @override
  State<MyCardDetail> createState() => _MyCardDetailState();
}

class _MyCardDetailState extends State<MyCardDetail> {
  final detailController = Get.put(CardDetailController());
  final StatusCardController statusCardController = Get.put(
    StatusCardController(),
  );
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    final String cardId = Get.arguments['card_id'];
    detailController.fetchCardDetail(cardId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'รายละเอียดบัตร',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
          ), //  Responsive Font
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF264FAD),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20.r,
          ), //  Responsive Icon
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final card = detailController.cardData;
        if (card.isEmpty)
          return const Center(child: CircularProgressIndicator());

        final String currentCardId = card['card_id'];
        final String ownerEn = homeController.fullNameEn.value;
        // final String cardName = card['card_name'];

        // ซิงค์สถานะ
        if (!statusCardController.isLoading.value) {
          statusCardController.isCardFrozen.value = card['status'] != 'active';
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ส่วนรูปบัตร
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                child: BankCard(
                  card: card,
                  ownerName: ownerEn,
                  cardName: card['card_name'],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 20.w, bottom: 10.h),

                child: Center(
                  child: Text(
                    "รายละเอียดบัตร",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),

              _buildDetailSection([
                // _buildRow("ชื่อ นามสกุล", homeController.fullNameTh.value),
                _buildRow(
                  "สถานะบัตร",
                  statusCardController.isCardFrozen.value
                      ? "ปิดใช้งาน"
                      : "เปิดใช้งาน",
                  valueColor: statusCardController.isCardFrozen.value
                      ? Colors.red
                      : Colors.green,
                ),
                // _buildRow("ผูกกับบัญชี", homeController.accountNumber.value),

                // ดูเลขบัตร (ซ่อนถ้าบัตรยังไม่เปิดใช้งาน)
                if (!(card['virtual'] == false && card['status'] == 'inactive'))
                  InkWell(
                    onTap: () => Get.toNamed(
                      '/pin_verify_page',
                      arguments: {
                        'action': 'view_sensitive',
                        'card': card,
                        'card_id': card['card_id'],
                        'ownerName': ownerEn,
                      },
                    ),
                    child: _buildRow("ดูเลขบัตร", "", showArrow: true),
                  ),
              ]),

              _buildSectionHeader("วงเงิน"),
              _buildDetailSection([
                _buildRow(
                  "วงเงินปัจจุบัน",
                  "${_formatMoney(card['current_spending_limit'])} บาท",
                  isBoldValue: true,
                ),
                if (!(card['virtual'] == false && card['status'] == 'inactive'))
                  InkWell(
                    onTap: () async {
                      await Get.toNamed(
                        '/change_limit_card',
                        arguments: {'card': card, 'ownerName': ownerEn},
                      );
                      detailController.fetchCardDetail(currentCardId);
                    },
                    child: _buildRow("ปรับวงเงิน", "", showArrow: true),
                  ),
              ]),
              if (!(card['virtual'] == false && card['status'] == 'inactive'))
                _buildSectionHeader("ความปลอดภัย"),
              _buildDetailSection([
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5.h,
                    horizontal: 15.w,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      if (!(card['virtual'] == false &&
                          card['status'] == 'inactive'))
                        Text(
                          "เปิดใช้งานบัตร",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      if (!(card['virtual'] == false &&
                          card['status'] == 'inactive'))
                        Transform.scale(
                          scale: 0.8.r, // ปรับขนาด Switch ให้พอดีจอ
                          child: Switch(
                            value: !statusCardController.isCardFrozen.value,
                            onChanged: (val) {
                              if (val)
                                statusCardController.unfreezeCard(currentCardId);
                              else
                                statusCardController.freezeCard(currentCardId);
                            },
                            activeColor: const Color(0xFF264FAD),
                          ),
                        ),
                    ],
                  ),
                ),
              ]),

              // ส่วนบัตร Physical
              if ((card['is_physical_requested'] == false &&
                      card['virtual'] == true) ||
                  (card['virtual'] == false &&
                      card['status'] == 'inactive')) ...[
                _buildSectionHeader("บัตร Physical"),
                _buildDetailSection([
                  if (card['virtual'] == true &&
                      card['is_physical_requested'] == false)
                    InkWell(
                      onTap: () => Get.toNamed(
                        '/requestPhysical',
                        arguments: {
                          'action': 'view_sensitive_for_activate',
                          'card': card,
                          'ownerName': ownerEn,
                        },
                      ),
                      child: _buildRow("ขอบัตร Physical", "", showArrow: true),
                    ),
                  if (card['virtual'] == false &&
                      card['status'] == 'inactive' &&
                      detailController.trackingData['delivery_status'] ==
                          'success')
                    InkWell(
                      onTap: () => Get.toNamed(
                        '/activate_physical',
                        arguments: {'card': card, 'ownerName': ownerEn},
                      ),
                      child: _buildRow(
                        "เปิดใช้งานบัตร Physical",
                        "",
                        showArrow: true,
                      ),
                    ),
                  if (card['virtual'] == false && card['status'] == 'inactive')
                    _buildRow(
                      "สถานะปัจจุบัน",
                      detailController.trackingData['delivery_status'] ??
                          "pending",
                      valueColor: Colors.blueAccent,
                      isBoldValue: true,
                    ),
                ]),
              ],
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, top: 15.h, bottom: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDetailSection(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool showArrow = false,
    bool isBoldValue = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 15.w),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: const Color(0xFF595858), fontSize: 14.sp),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isBoldValue
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                ),
                if (showArrow)
                  Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12.r,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(dynamic amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
