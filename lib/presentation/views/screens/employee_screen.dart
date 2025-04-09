import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/employee_model.dart';
import '../../../presentation/providers/employee_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';
import '../components/employee_bottom_sheet.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isInit = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carregar funcionários apenas na primeira vez
    if (!_isInit) {
      _loadEmployees();
      _isInit = true;
    }
  }

  Future<void> _loadEmployees() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.currentFarm != null) {
      final employeeProvider = Provider.of<EmployeeProvider>(
        context,
        listen: false,
      );
      await employeeProvider.loadEmployeesByFarmId(
        farmProvider.currentFarm!.id,
      );
    }
  }

  Future<void> _showAddEditEmployeeBottomSheet(
    BuildContext context, [
    Employee? employee,
  ]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SingleChildScrollView(
            child: EmployeeBottomSheet(employee: employee),
          ),
    );

    if (result == true) {
      // Recarregar lista se o funcionário foi adicionado/atualizado/excluído
      _loadEmployees();
    }
  }

  List<Employee> _filterEmployees(List<Employee> employees) {
    if (_searchQuery.isEmpty) {
      return employees;
    }

    return employees.where((employee) {
      return employee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee.role.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final filteredEmployees = _filterEmployees(employeeProvider.employees);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mão de Obra'),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditEmployeeBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa estilo WhatsApp iOS
          Container(
            color:
                isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar funcionários...',
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : AppTheme.warmBeige,
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? Colors.grey : Colors.grey[600],
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDarkMode ? Colors.grey : Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Lista de funcionários ou mensagem de lista vazia
          Expanded(
            child:
                employeeProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredEmployees.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : _buildEmployeeList(filteredEmployees, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 70,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum funcionário cadastrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro funcionário',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditEmployeeBottomSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Funcionário'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(List<Employee> employees, bool isDarkMode) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemCount: employees.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            indent: 80, // Indentação para alinhar com o avatar
          ),
      itemBuilder: (context, index) {
        final employee = employees[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
            child: Text(
              employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            employee.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.role,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              Text(
                'R\$ ${employee.cost.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          onTap: () => _showAddEditEmployeeBottomSheet(context, employee),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
        );
      },
    );
  }
}
