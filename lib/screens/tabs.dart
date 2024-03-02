import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_app/models/meal.dart';
import 'package:meal_app/providers/favorite_provider.dart';
import 'package:meal_app/providers/filters_provider.dart';
import 'package:meal_app/providers/meal_provider.dart';
import 'package:meal_app/screens/categories.dart';
import 'package:meal_app/screens/filters.dart';
import 'package:meal_app/screens/meals.dart';
import 'package:meal_app/widgets/main_drawer.dart';

// const kDefaultSelectedFilters = {
//   Filter.glutenFree: false,
//   Filter.lactoseFree: false,
//   Filter.veganFree: false,
//   Filter.vegetarianFree: false,
// };

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  // final List<Meal> _favoriteMeals = [];
  // Map<Filter, bool> _selectedFilters = kDefaultSelectedFilters;

  List<Meal> _buildAvailableMeals() {
    final meals = ref.watch(mealsProvider);
    final activeFilters = ref.watch(filtersProvider);
    return meals.where((meal) {
      if (activeFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }

      if (activeFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }

      if (activeFilters[Filter.veganFree]! && !meal.isVegan) {
        return false;
      }

      if (activeFilters[Filter.vegetarianFree]! && !meal.isVegetarian) {
        return false;
      }

      return true;
    }).toList();
  }

  void _selectScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'filters') {
      await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => const FiltersScreen(),
        ),
      );
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  String get _activeTitle =>
      _selectedPageIndex == 1 ? 'Favorites' : 'Pick Your category';

  Widget _buildWidget() {
    if (_selectedPageIndex == 1) {
      return MealsScreen(
        meals: ref.watch<List<Meal>>(favoriteMealsProvider),
      );
    }

    return CategoriesScreen(
      availableMeals: _buildAvailableMeals(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_activeTitle),
      ),
      drawer: MainDrawer(
        onSelectScreen: _selectScreen,
      ),
      body: _buildWidget(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
