import 'package:bizzu/theme/app_colors.dart';
import 'package:bizzu/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:bizzu/widgets/custom_app_bar.dart';
import 'package:bizzu/services/category_service.dart';
import 'package:bizzu/services/user_service.dart';
import 'package:bizzu/services/product_service.dart';

class PublishProductScreen extends StatefulWidget {
  const PublishProductScreen({super.key});

  @override
  State<PublishProductScreen> createState() => _PublishProductScreenState();
}

class _PublishProductScreenState extends State<PublishProductScreen> {
  // Form key to validate the form
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for the form fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  // Selected category for the product
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _publishProduct() {
    if (_formKey.currentState!.validate()) {
      final currentUser = UserService().currentUser;

      ProductService().addProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageController.text.trim(),
        categoryId: _selectedCategory!,
        sellerId: currentUser.id,
      );

      // Show a snackbar to indicate that the product has been published
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Producto publicado exitosamente'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryService().categories;

    return Scaffold(
      appBar: CustomAppBar(
        leadingIcon: Icons.arrow_back,
        leadingOnPressed: () {
          Navigator.pop(context);
        },
        title: 'BIZZU',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CustomTextField for product name
              CustomTextField(
                label: 'Nombre',
                hint: 'Ingrese el nombre del producto',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              // CustomTextField for product description
              CustomTextField(
                label: 'Descripción',
                hint: 'Ingrese la descripción del producto',
                maxLines: 3,
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción del producto';
                  }
                  return null;
                },
              ),
              // CustomTextField for product price
              CustomTextField(
                label: 'Precio',
                hint: 'Ingrese el precio del producto',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio del producto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Por favor ingresa un número mayor a cero';
                  }
                  return null;
                },
              ),
              // CustomTextField for product image URL
              CustomTextField(
                label: 'Imagen',
                hint: 'Ingrese la URL de la imagen del producto',
                controller: _imageController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la URL de la imagen del producto';
                  }
                  if (mounted && !Uri.tryParse(value)!.isAbsolute) {
                    return 'Por favor ingresa una URL válida';
                  }
                  return null;
                },
              ),
              // Dropdown for product category
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    isExpanded: true,
                    menuMaxHeight: 200,
                    borderRadius: BorderRadius.circular(12),
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      labelStyle: TextStyle(color: AppColors.textPrimaryLight),
                      hintText: 'Selecciona una categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona una categoría';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              // Button to submit the form
              ElevatedButton(
                onPressed: _publishProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Publicar Producto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
