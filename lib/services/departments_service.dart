import 'dart:convert';
import 'package:flutter/services.dart';

/// خدمة لتحميل وإدارة بيانات الإدارات من ملف JSON
class DepartmentsService {
  static final DepartmentsService _instance = DepartmentsService._internal();
  factory DepartmentsService() => _instance;
  DepartmentsService._internal();

  // البنية الجديدة: إدارة تنفيذية -> إدارة رئيسية -> إدارة فرعية
  Map<String, Map<String, List<String>>> _departmentsData = {};
  bool _isLoaded = false;

  /// الحصول على بيانات الإدارات
  Map<String, Map<String, List<String>>> get departmentsData => Map.from(_departmentsData);

  /// التحقق من تحميل البيانات
  bool get isLoaded => _isLoaded;

  /// تحميل بيانات الإدارات من ملف JSON
  /// 
  /// يقرأ ملف departments.json من assets ويحوله إلى هيكل البيانات المطلوب
  Future<Map<String, Map<String, List<String>>>> loadDepartments() async {
    if (_isLoaded) {
      return _departmentsData;
    }

    try {
      // تحميل ملف JSON من assets
      final String jsonString = await rootBundle.loadString('assets/departments.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // مسح البيانات الموجودة
      _departmentsData.clear();

      // تحويل البيانات من JSON إلى هيكل البيانات المطلوب
      for (final item in jsonData) {
        final executiveDept = item['هيكلة الإدارة']?.toString().trim();
        final mainDept = item['إسم الإدارة الرئيسية']?.toString().trim();
        final subDept = item['إسم الإدارة الفرعية']?.toString().trim();
        
        if (executiveDept != null && mainDept != null && subDept != null && 
            executiveDept.isNotEmpty && mainDept.isNotEmpty && subDept.isNotEmpty) {
          
          // إضافة الإدارة التنفيذية إذا لم تكن موجودة
          if (!_departmentsData.containsKey(executiveDept)) {
            _departmentsData[executiveDept] = {};
          }
          
          // إضافة الإدارة الرئيسية إذا لم تكن موجودة
          if (!_departmentsData[executiveDept]!.containsKey(mainDept)) {
            _departmentsData[executiveDept]![mainDept] = [];
          }
          
          // إضافة القسم الفرعي إذا لم يكن موجوداً
          if (!_departmentsData[executiveDept]![mainDept]!.contains(subDept)) {
            _departmentsData[executiveDept]![mainDept]!.add(subDept);
          }
        }
      }

      // ترتيب القوائم أبجدياً
      for (final execKey in _departmentsData.keys) {
        for (final mainKey in _departmentsData[execKey]!.keys) {
          _departmentsData[execKey]![mainKey]!.sort();
        }
      }

      _isLoaded = true;
      return _departmentsData;
    } catch (e) {
      // في حالة الخطأ، استخدام البيانات الافتراضية
      _departmentsData = _getDefaultDepartments();
      _isLoaded = true;
      throw Exception('خطأ في تحميل بيانات الإدارات من JSON، تم استخدام البيانات الافتراضية: $e');
    }
  }

  /// البيانات الافتراضية في حالة فشل تحميل ملف JSON
  Map<String, Map<String, List<String>>> _getDefaultDepartments() {
    return {
      'الإدارة التنفيذية العليا': {
        'الشئون القانونية والإلتزام': [
          'الشئون القانونية',
          'الإلتزام',
        ],
        'الشئون الفنية والتنظيمية': [
          'مكتب الرئيس التنفيذي',
          'تطوير الأعمال',
          'الزائر السري',
          'الحج والعمرة',
        ],
        'الشئون الإدارية': [
          'الإتصالات الإدارية',
          'الخدمات العامة',
        ],
      },
      'الإدارة التنفيذية للتميز الصحي': {
        'إدارة الصحة السكانية': [
          'تحليلات إدارة صحة السكان',
          'تسجيل السكان',
          'تصنيف المخاطر والتنبؤات الصحية',
        ],
        'إدارة الصحة العامة': [
          'برامج الصحة العامة',
          'مكافحة العدوى',
          'الوقاية من الأمراض المعدية',
          'السجون',
          'صحة البيئة والصحة المهنية',
          'التعزيز والتثقيف الصحي',
          'نواقل المرض والمراض المشتركة',
        ],
      },
    };
  }

  /// الحصول على قائمة الإدارات التنفيذية
  List<String> getExecutiveDepartments() {
    return _departmentsData.keys.toList()..sort();
  }

  /// الحصول على قائمة الإدارات الرئيسية لإدارة تنفيذية معينة
  List<String> getMainDepartments(String executiveDepartment) {
    final mainDepts = _departmentsData[executiveDepartment]?.keys.toList() ?? [];
    return mainDepts..sort();
  }

  /// الحصول على قائمة الأقسام الفرعية لإدارة رئيسية معينة
  List<String> getSubDepartments(String executiveDepartment, String mainDepartment) {
    return _departmentsData[executiveDepartment]?[mainDepartment] ?? [];
  }

  /// البحث في الإدارات
  Map<String, Map<String, List<String>>> searchDepartments(String query) {
    if (query.isEmpty) return _departmentsData;

    final result = <String, Map<String, List<String>>>{};
    
    for (final execEntry in _departmentsData.entries) {
      final executiveDept = execEntry.key;
      final mainDepartments = execEntry.value;
      
      // البحث في اسم الإدارة التنفيذية
      if (executiveDept.contains(query)) {
        result[executiveDept] = mainDepartments;
        continue;
      }
      
      // البحث في الإدارات الرئيسية والفرعية
      final matchingMainDepts = <String, List<String>>{};
      
      for (final mainEntry in mainDepartments.entries) {
        final mainDept = mainEntry.key;
        final subDepartments = mainEntry.value;
        
        // البحث في اسم الإدارة الرئيسية
        if (mainDept.contains(query)) {
          matchingMainDepts[mainDept] = subDepartments;
          continue;
        }
        
        // البحث في أسماء الأقسام الفرعية
        final matchingSubDepts = subDepartments
            .where((subDept) => subDept.contains(query))
            .toList();
        
        if (matchingSubDepts.isNotEmpty) {
          matchingMainDepts[mainDept] = matchingSubDepts;
        }
      }
      
      if (matchingMainDepts.isNotEmpty) {
        result[executiveDept] = matchingMainDepts;
      }
    }
    
    return result;
  }

  /// إعادة تحميل البيانات
  Future<void> reload() async {
    _isLoaded = false;
    _departmentsData.clear();
    await loadDepartments();
  }

  /* 
  // مثال لتطبيق قراءة ملف Excel الفعلي
  // يحتاج إلى حزمة excel: ^4.0.6
  
  Future<Map<String, List<String>>> _loadFromExcel() async {
    try {
      final ByteData data = await rootBundle.load('assets/__الإدارات وفروعها_.xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
      final Excel excel = Excel.decodeBytes(bytes);
      
      final result = <String, List<String>>{};
      
      for (final tableName in excel.tables.keys) {
        final table = excel.tables[tableName]!;
        
        for (int row = 1; row < table.maxRows; row++) { // تجاهل صف الرؤوس
          final executiveDept = table.cell(CellIndex.indexByColumnRow(
            columnIndex: 0, 
            rowIndex: row
          )).value?.toString().trim();
          
          final department = table.cell(CellIndex.indexByColumnRow(
            columnIndex: 1, 
            rowIndex: row
          )).value?.toString().trim();
          
          if (executiveDept != null && department != null && 
              executiveDept.isNotEmpty && department.isNotEmpty) {
            result.putIfAbsent(executiveDept, () => []);
            if (!result[executiveDept]!.contains(department)) {
              result[executiveDept]!.add(department);
            }
          }
        }
      }
      
      // ترتيب القوائم
      for (final key in result.keys) {
        result[key]!.sort();
      }
      
      return result;
    } catch (e) {
      throw Exception('فشل في قراءة ملف Excel: $e');
    }
  }
  */
}
