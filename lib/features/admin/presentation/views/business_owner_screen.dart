import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_safwa/features/admin/presentation/manager/admin_cubit/business_cubit.dart';

class BusinessOwnerScreen extends StatefulWidget {
  const BusinessOwnerScreen({Key? key}) : super(key: key);

  @override
  State<BusinessOwnerScreen> createState() => _BusinessOwnerScreenState();
}

class _BusinessOwnerScreenState extends State<BusinessOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _factoryController;
  bool _isSaved = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final owner = context.read<BusinessCubit>().state;
    _nameController = TextEditingController(text: owner?.name ?? '');
    _phoneController = TextEditingController(text: owner?.phone ?? '');
    _factoryController = TextEditingController(text: owner?.factory ?? '');
    _isSaved = owner != null;
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(_isSaved ? 'تعديل البيانات' : 'تسجيل بيانات صاحب العمل'),
        centerTitle: true,
        elevation: 0,
        actions: _isSaved ? [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEditing,
          )
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isSaved ? _toggleEditing : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: _isSaved ? 100 : 200,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 500),
                        scale: _isSaved ? 0.8 : 1,
                        child: CircleAvatar(
                          radius: _isSaved ? 40 : 60,
                          backgroundColor: Colors.blue.shade800,
                          child: Icon(
                            Icons.person,
                            size: _isSaved ? 40 : 60,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      if (_isSaved)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode ? Colors.black : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _isEditing ? Icons.close : Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        enabled: !_isSaved || _isEditing,
                        decoration: InputDecoration(
                          labelText: 'اسم صاحب العمل',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: _isSaved && !_isEditing,
                          fillColor: Colors.grey.withOpacity(0.1),
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _isSaved && !_isEditing 
                              ? Colors.grey 
                              : theme.textTheme.bodyLarge?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يجب إدخال الاسم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        enabled: !_isSaved || _isEditing,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: const Icon(Icons.phone_android),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: _isSaved && !_isEditing,
                          fillColor: Colors.grey.withOpacity(0.1),
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _isSaved && !_isEditing 
                              ? Colors.grey 
                              : theme.textTheme.bodyLarge?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يجب إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _factoryController,
                        enabled: !_isSaved || _isEditing,
                        decoration: InputDecoration(
                          labelText: 'اسم المصنع',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: _isSaved && !_isEditing,
                          fillColor: Colors.grey.withOpacity(0.1),
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _isSaved && !_isEditing 
                              ? Colors.grey 
                              : theme.textTheme.bodyLarge?.color,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يجب إدخال الاسم';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),
                      if (_isEditing || !_isSaved)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveOwnerInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              _isSaved ? 'تحديث البيانات' : 'حفظ البيانات',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOwnerInfo() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<BusinessCubit>().saveOwner(
            _nameController.text.trim(),
            _phoneController.text.trim(),
            _factoryController.text.trim(),
          );

      if (success && mounted) {
        setState(() {
          _isSaved = true;
          _isEditing = false;
        });
        
        await _showSuccessDialog(context);
      }
    }
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'تم الحفظ بنجاح',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          _isSaved 
              ? 'تم تحديث بيانات صاحب العمل بنجاح'
              : 'تم تسجيل بيانات صاحب العمل بنجاح',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تم'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}