import 'package:bsuir/resourses/app_fonts.dart';
import 'package:bsuir/ui/widgets/app/main_screen/main_screen_model.dart';
import 'package:bsuir/ui/widgets/app/search_widget/search_group_widget.dart.dart';
import 'package:bsuir/ui/widgets/app/search_widget/search_group_model.dart';
import 'package:bsuir/ui/widgets/app/search_widget/search_teacher_model.dart';
import 'package:bsuir/ui/widgets/app/search_widget/search_teacher_widget.dart';
import 'package:bsuir/ui/widgets/inherited/provider.dart';
import 'package:flutter/material.dart';

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({super.key});

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  int _selectedTab = 0;
  String _title = 'Группы';

  final getTeacherModel = SearchTeacherModel();
  final getGroupModel = SearchGroupModel();

  void onselectTab(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
      switch (index) {
        case 0:
          _title = 'Группы';
        case 1:
          _title = 'Преподаватели';
        case 2:
          _title = 'Настройки';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getTeacherModel.getAllTeachers();
    getGroupModel.getAllGroups();
  }

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.read<MainScreenModel>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            height: 1.3,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFf3f2f8),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          // SearchGroupModelProvider(
          //   model: getGroupModel,
          //   child: const SearchGroupWidget(),
          // ),
NotifierProvider(
            create: () => getGroupModel,
            isManagingModel: false,
            child: const SearchGroupWidget(),
          ),

          
          NotifierProvider(
            create: () => getTeacherModel,
            isManagingModel: false,
            child: const SearchTeacherWidget(),
          ),

          // SearchTeacherModelProvider(
          //   model: getTeacherModel,
          //   child: const SearchTeacherWidget(),
          // ),
          Text('WWWWWWWWWWWW'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle: const TextStyle(
          color: Color(0xFF88898d),
          fontSize: 12,
          height: 1.3,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w500,
        ),
        unselectedItemColor: Color(0xFF88898d),
        backgroundColor: const Color(0xFFf3f2f8),
        selectedLabelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          height: 1.3,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w500,
        ),
        selectedItemColor: Colors.black,
        currentIndex: _selectedTab,

        items: [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Группы'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: 'Преподаватели',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
        onTap: onselectTab,
      ),
    );
  }
}
