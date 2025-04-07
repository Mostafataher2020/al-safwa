import 'dart:io';
import 'package:al_safwa/features/home/data/models/sale_transaction%20.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:al_safwa/features/admin/data/models/business_owner.dart';
import 'package:al_safwa/features/home/data/models/customer.dart';

class InvoiceExporter {
  static Future<void> exportToExcel({
    required BusinessOwner? businessOwner,
    required Customer customer,
    required SaleTransaction transaction,
    required double totalAmount,
    required double paidAmount,
    required double remainingAmount,
  }) async {
    // إنشاء ملف Excel جديد
    final excel = Excel.createExcel();
    final sheet = excel['فاتورة'];

    // إضافة معلومات صاحب العمل
    _addHeader(sheet, 'معلومات صاحب العمل');
    _addRow(sheet, ['الاسم:', businessOwner?.name ?? 'غير محدد']);
    _addRow(sheet, ['رقم الهاتف:', businessOwner?.phone ?? 'غير محدد']);
    _addEmptyRow(sheet);
    
    // إضافة معلومات العميل
    _addHeader(sheet, 'معلومات العميل');
    _addRow(sheet, ['الاسم:', customer.name]);
    _addRow(sheet, ['رقم الهاتف:', customer.phoneNumber]);
    if (customer.address != null) {
      _addRow(sheet, ['العنوان:', customer.address!]);
    }
    _addEmptyRow(sheet);

    // إضافة تفاصيل الفاتورة
    _addHeader(sheet, 'تفاصيل الفاتورة');
    _addRow(sheet, ['تاريخ الفاتورة:', transaction.date.toString()]);
    if (transaction.productName != null) {
      _addRow(sheet, ['اسم المنتج:', transaction.productName!]);
    }
    if (transaction.quantity != null) {
      _addRow(sheet, ['الكمية:', transaction.quantity.toString()]);
    }
    if (transaction.unitPrice != null) {
      _addRow(sheet, ['سعر الوحدة:', transaction.unitPrice.toString()]);
    }
    _addRow(sheet, ['طريقة الدفع:', transaction.paymentMethod]);
    _addRow(sheet, ['الإجمالي:', totalAmount.toString()]);
    _addRow(sheet, ['المبلغ المدفوع:', paidAmount.toString()]);
    _addRow(sheet, ['المبلغ المتبقي:', remainingAmount.toString()]);

    // حفظ الملف مؤقتًا
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/فاتورة_${customer.name}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    // مشاركة الملف
    await Share.shareXFiles([XFile(filePath)], text: 'فاتورة ${customer.name}');
  }

  static void _addHeader(Sheet sheet, String title) {
    final cell = sheet.cell(CellIndex.indexByString('A${sheet.rows.length + 1}'));
    // cell.value = title;
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.blue, // أزرق
    );
  }

  static void _addRow(Sheet sheet, List<dynamic> values) {
    final rowIndex = sheet.rows.length;
    for (int i = 0; i < values.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
      cell.value = values[i];
    }
  }

  static void _addEmptyRow(Sheet sheet) {
    sheet.appendRow([]);
  }
}