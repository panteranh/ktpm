import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Add kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mangaapp1/models/comic_model.dart';

enum ImageSourceType { url, upload }

class AddComicPage extends StatefulWidget {
  final Comic? comic; // Optional comic for editing mode

  const AddComicPage({Key? key, this.comic}) : super(key: key);

  @override
  State<AddComicPage> createState() => _AddComicPageState();
}

class _AddComicPageState extends State<AddComicPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _coverUrlController;

  // State
  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Horror', 'Magic', 
    'Mecha', 'Mystery', 'Psychological', 'Romance', 'Sci-Fi', 'Slice of Life'
  ];
  List<String> _selectedGenres = [];
  String _selectedStatus = 'Ongoing';
  ImageSourceType _imageSource = ImageSourceType.url;
  File? _imageFile;
  XFile? _webImage; // Store XFile for web support
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if in edit mode
    _titleController = TextEditingController(text: widget.comic?.title ?? '');
    _authorController = TextEditingController(text: widget.comic?.author ?? '');
    _descriptionController = TextEditingController(text: widget.comic?.description ?? '');
    _coverUrlController = TextEditingController(text: widget.comic?.cover ?? '');
    
    if (widget.comic != null) {
      _selectedStatus = widget.comic!.status;
      _selectedGenres = widget.comic!.genre.split(', ').where((s) => s.isNotEmpty).toList();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _webImage = pickedFile;
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destination = 'comic_covers/$fileName';
      final ref = FirebaseStorage.instance.ref(destination);
      
      if (kIsWeb && _webImage != null) {
        final bytes = await _webImage!.readAsBytes();
        await ref.putData(bytes);
      } else if (_imageFile != null) {
        await ref.putFile(_imageFile!);
      } else {
        return null;
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveComic() async {
    if (!_formKey.currentState!.validate() || (_selectedGenres.isEmpty)) return;

    setState(() => _isUploading = true);

    String? coverUrl;
    if (_imageSource == ImageSourceType.upload && (kIsWeb ? _webImage != null : _imageFile != null)) {
      coverUrl = await _uploadImage();
    } else {
      coverUrl = _coverUrlController.text.trim();
    }

    final comicData = {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
      'genre': _selectedGenres.join(', '),
      'description': _descriptionController.text.trim(),
      'cover': coverUrl,
      'status': _selectedStatus,
      'updatedAt': Timestamp.now(),
    };

    try {
      if (widget.comic == null) {
        // Create Mode
        comicData['createdAt'] = Timestamp.now();
        await FirebaseFirestore.instance.collection('comics').add(comicData);
      } else {
        // Edit Mode
        await FirebaseFirestore.instance.collection('comics').doc(widget.comic!.id).update(comicData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.comic != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa truyện' : 'Thêm truyện mới'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên truyện', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên truyện' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Tác giả', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tác giả' : null,
              ),
              const SizedBox(height: 16),
              _buildGenreSection(),
              const SizedBox(height: 16),
              _buildStatusSection(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isUploading ? null : _saveComic,
                child: Text(_isUploading ? 'Đang xử lý...' : (isEditMode ? 'Cập nhật truyện' : 'Lưu truyện')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imageSource == ImageSourceType.url)
          TextFormField(
            controller: _coverUrlController,
            decoration: const InputDecoration(labelText: 'URL ảnh bìa', border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          )
        else
          _buildImageUpload(),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Nguồn ảnh: '),
            TextButton(
              onPressed: () => setState(() => _imageSource = ImageSourceType.url),
              child: Text('Từ URL', style: TextStyle(color: _imageSource == ImageSourceType.url ? Colors.deepPurple : Colors.grey)),
            ),
            TextButton(
              onPressed: () => setState(() => _imageSource = ImageSourceType.upload),
              child: Text('Tải lên', style: TextStyle(color: _imageSource == ImageSourceType.upload ? Colors.deepPurple : Colors.grey)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildImageUpload() {
    bool hasFile = kIsWeb ? _webImage != null : _imageFile != null;
    return Column(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: hasFile
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(7), 
                  child: kIsWeb 
                    ? Image.network(_webImage!.path, fit: BoxFit.cover) // Web uses NetworkImage for preview
                    : Image.file(_imageFile!, fit: BoxFit.cover)
                )
              : const Center(child: Text('Chưa chọn ảnh')),
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _pickImage, child: const Text('Chọn ảnh từ máy')),
      ],
    );
  }

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thể loại: ${_selectedGenres.isEmpty ? "Chưa chọn" : _selectedGenres.join(", ")}'),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _showGenrePickerDialog, child: const Text('Chọn thể loại')),
      ],
    );
  }

  Widget _buildStatusSection() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
      items: ['Ongoing', 'Completed', 'Hiatus'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _selectedStatus = v!),
    );
  }

  Future<void> _showGenrePickerDialog() async {
    final tempSelected = List<String>.from(_selectedGenres);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn thể loại'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              children: _availableGenres.map((g) => FilterChip(
                label: Text(g),
                selected: tempSelected.contains(g),
                onSelected: (selected) {
                  setDialogState(() {
                    selected ? tempSelected.add(g) : tempSelected.remove(g);
                  });
                },
              )).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(onPressed: () {
            setState(() => _selectedGenres = tempSelected);
            Navigator.pop(context);
          }, child: const Text('Chọn')),
        ],
      ),
    );
  }
}
