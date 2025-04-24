import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:student_attendance/cubits/theme_cubit/theme_cubit.dart';
import 'package:student_attendance/models/subject_model.dart';

// import 'widgets_dropdown_button_ex.dart';

/// Data class to visualize.
class _CostsData {
  final String name;
  final int number;

  const _CostsData(this.name, this.number);
}

class PieChartExample extends StatefulWidget {
  const PieChartExample(
      {super.key, required this.subjectModel, required this.presentStudent});

  final SubjectModel subjectModel;
  final String presentStudent;

  @override
  _PieChartExampleState createState() => _PieChartExampleState();
}

class _PieChartExampleState extends State<PieChartExample> {
  // Chart configs.
  // final bool _animate = true;
  // final bool _defaultInteractions = true;
  // double _arcRatio = 0.8;
  // final charts.ArcLabelPosition _arcLabelPosition = charts.ArcLabelPosition.auto;
  // final charts.BehaviorPosition _titlePosition = charts.BehaviorPosition.bottom;
  // final charts.BehaviorPosition _legendPosition = charts.BehaviorPosition.bottom;

  // Data to render.
  late List<_CostsData> _data;

  @override
  void initState() {
    super.initState();
    _data = [
      _CostsData('Present', int.parse(widget.presentStudent)),
      _CostsData(
          'Absent',
          widget.subjectModel.studentList.length -
              int.parse(widget.presentStudent)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorPalettes =
        charts.MaterialPalette.getOrderedPalettes(_data.length);
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: 300.h,
              // MUST specify the type T, see https://github.com/google/charts/issues/668#issuecomment-943556524.
              child: charts.PieChart<String>(
                // Pie chart can only render one series.
                /*seriesList=*/ [
                  charts.Series<_CostsData, String>(
                    id: 'Sales-1',
                    colorFn: (data, idx) {
                      if (data.name == 'Present') {
                        return charts.MaterialPalette.green.shadeDefault;
                      } else if (data.name == 'Absent') {
                        return charts.MaterialPalette.red.shadeDefault;
                      }
                      return colorPalettes[idx!].shadeDefault;
                    },
                    domainFn: (_CostsData sales, _) => sales.name,
                    measureFn: (_CostsData sales, _) => sales.number,
                    data: _data,
                    // Set a label accessor to control the text of the arc label.
                    labelAccessorFn: (_CostsData row, _) =>
                        '${row.name}: ${row.number}',
                    insideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(
                      fontSize: 18.sp.toInt(),
                      color: themeMode == ThemeMode.light
                          ? charts.Color.black
                          : charts.Color.white,
                    ),
                    outsideLabelStyleAccessorFn: (_, __) =>
                        charts.TextStyleSpec(
                      fontSize: 18.sp.toInt(),
                      color: themeMode == ThemeMode.light
                          ? charts.Color.black
                          : charts.Color.white,
                    ),
                  ),
                ],
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcRatio: 0.97,
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator(
                        labelPosition: charts.ArcLabelPosition.auto)
                  ],
                ),
                behaviors: [
                  // Add title.
                  charts.ChartTitle(
                    'Statistics',
                    behaviorPosition: charts.BehaviorPosition.bottom,
                    titleStyleSpec: charts.TextStyleSpec(
                      fontSize: 30.sp.toInt(),
                      color: themeMode == ThemeMode.light
                          ? charts.Color.black
                          : charts.Color.white,
                    ),
                  ),
                  // Add legend. ("Datum" means the "X-axis" of each data point.)
                  charts.DatumLegend(
                    //font size
                    cellPadding: EdgeInsets.only(
                      right: 130.w,
                    ),
                    entryTextStyle: charts.TextStyleSpec(
                      fontSize: 25.sp.toInt(),
                      // color: charts.Color.black,
                    ),
                    position: charts.BehaviorPosition.bottom,
                    desiredMaxRows: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}


/*

import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

class PieChartExample extends StatelessWidget {
  const PieChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      _CostsData('Category A', 30),
      _CostsData('Category B', 70),
    ];

    final series = [
      charts.Series<_CostsData, String>(
        id: 'Costs',
        domainFn: (_CostsData costs, _) => costs.category,
        measureFn: (_CostsData costs, _) => costs.cost,
        data: data,
        labelAccessorFn: (_CostsData row, _) => '${row.category}: ${row.cost}',
      ),
    ];

    return SizedBox(
      height: 300,
      child: charts.PieChart<String>(
        series,
        animate: true,
        defaultRenderer: charts.ArcRendererConfig(
          arcRendererDecorators: [charts.ArcLabelDecorator()],
        ),
      ),
    );
  }
}

class _CostsData {
  final String category;
  final int cost;

  _CostsData(this.category, this.cost);
}


 */