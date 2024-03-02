import 'package:flutter/material.dart';
import 'package:meal_app/data/dummy_data.dart';
import 'package:meal_app/models/meal.dart';
import 'package:meal_app/screens/categories.dart';
import 'package:meal_app/screens/filters.dart';
import 'package:meal_app/screens/meals.dart';
import 'package:meal_app/widgets/main_drawer.dart';

const kDefaultSelectedFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.veganFree: false,
  Filter.vegetarianFree: false,
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoriteMeals = [];
  Map<Filter, bool> _selectedFilters = kDefaultSelectedFilters;

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(super.context).clearSnackBars();
    ScaffoldMessenger.of(super.context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  List<Meal> _buildAvailableMeals() {
    return dummyMeals.where((meal) {
      if (_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }

      if (_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }

      if (_selectedFilters[Filter.veganFree]! && !meal.isVegan) {
        return false;
      }

      if (_selectedFilters[Filter.vegetarianFree]! && !meal.isVegetarian) {
        return false;
      }

      return true;
    }).toList();
  }

  void _toggleMealFavoriteStatus(Meal meal) {
    final isExisting = _favoriteMeals.contains(meal);

    if (isExisting) {
      setState(() {
        _favoriteMeals.remove(meal);
        _showInfoMessage('Meal is no longer a favorite.');
      });
    } else {
      setState(() {
        _favoriteMeals.add(meal);
        _showInfoMessage('Marked as a favorite meal.');
      });
    }
  }

  void _selectScreen(String identifier) async {
    // if (identifier == 'filters') {
    //   Navigator.of(context).pop();
    //   Navigator.of(context)
    //       .push(MaterialPageRoute(builder: (ctx) => const FiltersScreen()));
    // } else {
    //   Navigator.of(context).pop();
    // }

    Navigator.of(context).pop();
    if (identifier == 'filters') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => FiltersScreen(
            currentFilters: _selectedFilters,
          ),
        ),
      );

      setState(() {
        _selectedFilters = result ?? kDefaultSelectedFilters;
      });
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
        meals: _favoriteMeals,
        onToggleFavorite: _toggleMealFavoriteStatus,
      );
    }

    return CategoriesScreen(
      onToggleFavorite: _toggleMealFavoriteStatus,
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
