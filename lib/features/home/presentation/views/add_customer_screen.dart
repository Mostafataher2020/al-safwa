import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_safwa/features/home/data/models/customer.dart';
import 'package:al_safwa/features/home/presentation/manager/customers_cubit/customer_cubit.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;
  final bool isEditing;

  const AddCustomerScreen({
    super.key,
    this.customer,
  }) : isEditing = customer != null;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfilePicture(),
                const SizedBox(height: 32),
                _buildNameField(theme),
                const SizedBox(height: 20),
                _buildPhoneField(theme),
                const SizedBox(height: 20),
                _buildEmailField(theme),
                const SizedBox(height: 20),
                _buildAddressField(theme),
                const SizedBox(height: 40),
                _buildActionButtons(context, isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        widget.isEditing ? 'تعديل بيانات العميل' : 'عميل جديد',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: theme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (widget.isEditing)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _confirmDelete,
          ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade100,
              border: Border.all(
                color: Colors.blue.shade800,
                width: 2,
              ),
              image: widget.customer?.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.customer!.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.customer?.imageUrl == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.blue.shade800,
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'الاسم الكامل',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: theme.textTheme.bodyLarge,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يجب إدخال اسم العميل';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      autofocus: !widget.isEditing,
    );
  }
Widget _buildPhoneField(ThemeData theme) {
  return TextFormField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    decoration: InputDecoration(
      labelText: 'رقم الهاتف',
      prefixIcon: const Icon(Icons.phone_android),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly, // يقبل الأرقام فقط
      LengthLimitingTextInputFormatter(15), // أقصى طول 15 رقم
    ],
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'يجب إدخال رقم الهاتف';
      }
      if (value.length < 11) { // التحقق من أن الرقم 11 رقم أو أكثر
        return 'يجب أن يكون رقم الهاتف 11 رقماً على الأقل';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return 'يجب أن يحتوي على أرقام فقط';
      }
      return null;
    },
    textInputAction: TextInputAction.next,
  );
}

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني (اختياري)',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: theme.textTheme.bodyLarge,
      validator: (value) {
        if (value != null && value.isNotEmpty && !value.contains('@')) {
          return 'يجب أن يكون بريدًا إلكترونيًا صحيحًا';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildAddressField(ThemeData theme) {
    return TextFormField(
      controller: _addressController,
      keyboardType: TextInputType.streetAddress,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'العنوان (اختياري)',
        prefixIcon: const Icon(Icons.location_on_outlined),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      style: theme.textTheme.bodyLarge,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Text(
            widget.isEditing ? 'حفظ التعديلات' : 'إضافة العميل',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.isEditing) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف العميل ${_nameController.text}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<CustomerCubit>().deleteCustomer(_nameController.text);
      Navigator.pop(context);
    }
  }

void _submitForm() {
  if (_formKey.currentState!.validate()) {
    final customer = Customer(
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      transactions: widget.customer?.transactions ?? [],
    );

    if (widget.isEditing) {
      context.read<CustomerCubit>().updateCustomer(
        widget.customer!.name,
        customer,
      );
    } else {
      context.read<CustomerCubit>().addCustomer(customer);
    }

    Navigator.pop(context);
  }
}
}