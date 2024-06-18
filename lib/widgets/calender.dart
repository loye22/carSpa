import 'dart:io';

import 'package:car_spa/widgets/dialog.dart';
import 'package:car_spa/widgets/staticVar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

class calenderView extends StatefulWidget {
  const calenderView({super.key});

  @override
  State<calenderView> createState() => _calenderViewState();
}

class _calenderViewState extends State<calenderView> {
  List<Map<String, dynamic>> ordersfromFirebase = [];
  bool isLoading = false;

  final CalendarController<Event> controller = CalendarController(
    calendarDateTimeRange: DateTimeRange(
      start: DateTime(DateTime.now().year - 1),
      end: DateTime(DateTime.now().year + 1),
    ),
  );
  final CalendarEventsController<Event> eventController =
      CalendarEventsController<Event>();

  late ViewConfiguration currentConfiguration = viewConfigurations[0];
  List<ViewConfiguration> viewConfigurations = [
    CustomMultiDayConfiguration(

      showMultiDayHeader: false ,
      name: 'Day',
      numberOfDays: 1,
      startHour: 6,
      endHour: 24,
      createEvents: false,
    ),
    WeekConfiguration(
      showMultiDayHeader: true ,
      startHour: 6,
      endHour: 24,
      createEvents: false,
    ),
    MonthConfiguration(),
    MultiWeekConfiguration(
      numberOfWeeks: 3,
      startHour: 6,
      endHour: 24,
      createEvents: false,
    ),
    ScheduleConfiguration(showHeader: true)
  ];

  @override
  void initState() {
    super.initState();
    ordersFromFirrbase();
  }

  @override
  Widget build(BuildContext context) {
    final calendar = CalendarView<Event>(
      style: CalendarStyle(
          backgroundColor: Colors.black,
          calendarHeaderBackgroundStyle: CalendarHeaderBackgroundStyle(
              headerBackgroundColor: Colors.white)),
      controller: controller,
      eventsController: eventController,
      viewConfiguration: currentConfiguration,
      tileBuilder: _tileBuilder,
      multiDayTileBuilder: _multiDayTileBuilder,
      scheduleTileBuilder: _scheduleTileBuilder,
      components: CalendarComponents(
        calendarHeaderBuilder: _calendarHeader,
      ),
      eventHandlers: CalendarEventHandlers(
        onEventTapped: _onEventTapped,
        onEventChanged: _onEventChanged,
      ),
    );

    return SafeArea(
      child: Scaffold(
        body: calendar,
      ),
    );
  }

  Future<void> ordersFromFirrbase() async {
    this.isLoading = true;
    setState(() {});
    // Initialize Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Define a list to store the fetched data
    List<Map<String, dynamic>> ordersList = [];

    try {
      // Get all documents from the 'services' collection
      QuerySnapshot querySnapshot = await firestore
          .collection('orders')
          .orderBy('issuedDate', descending: true)
          .get();

      // Loop through the documents snapshot
      querySnapshot.docs.forEach((doc) {
        // Get document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Add document ID to the data map
        data['docId'] = doc.id;

        // Add data map to the list
        ordersList.add(data);
      });

      this.ordersfromFirebase = ordersList;
      eventController.addEvents(this
          .ordersfromFirebase
          .map((e) => CalendarEvent(
                modifiable: false,
                dateTimeRange: DateTimeRange(
                  start: e["appointmentDate"].toDate() ?? DateTime.now(),
                  end: e["expectedFinishingDate"].toDate() ??
                      DateTime.now().add(Duration(days: 5)),
                ),
                eventData: Event(
                  orderData: e ?? {} ,
                  date:staticVar.formatDateFromTimestamp(e["appointmentDate"] ?? "")  ,
                  title: e["carModel"]?? "404Notfound" ,
                  color: staticVar.getNextColor() , //staticVar.getOrderStatusColor(status2: e["status"] ?? "404"),
                    employee: e["empName"] ?? "404Notfound",
                  servises: e["selectedServices"]?.map((e) => e["serviceName"])?.toList()?.toString() ?? "404Eror"

                ),
              ))
          .toList());

      this.isLoading = false;
      setState(() {});
      // print(this.ordersfromFirebase);
    } catch (e) {
      this.isLoading = false;
      setState(() {});
      // Print any errors for debugging purposes
      //print('Error fetching : $e');
      MyDialog.showAlert(context, "Ok", 'Error fetching orders: $e');
    }
  }

  Future<void> _onEventTapped(
    CalendarEvent<Event> event,
  ) async {
    MyDialog.showOrderDetailsPopup(context: context, orderData: event.eventData!.orderData);
    //print(event.eventData!.title.toString());
  }

  Future<void> _onEventChanged(
    DateTimeRange initialDateTimeRange,
    CalendarEvent<Event> event,
  ) async {
    MyDialog.showAlert(context, "Ok", event.eventData!.title.toString());
  }

  Widget _tileBuilder(
    CalendarEvent<Event> event,
    TileConfiguration configuration,
  ) {
    final color = event.eventData?.color ?? Colors.blue;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
      elevation: configuration.tileType == TileType.ghost ? 0 : 8,
      color: configuration.tileType != TileType.ghost
          ? color
          : color.withAlpha(100),
      child: Center(
        child: configuration.tileType != TileType.ghost
            ? Text(event.eventData?.title ?? 'New Event')
            : null,
      ),
    );
  }

  Widget _multiDayTileBuilder(
    CalendarEvent<Event> event,
    MultiDayTileConfiguration configuration,
  ) {
    final color = event.eventData?.color ?? Colors.blue;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: configuration.tileType == TileType.selected ? 8 : 0,
      color: configuration.tileType == TileType.ghost
          ? color.withAlpha(100)
          : color,
      child: Center(
        child: configuration.tileType != TileType.ghost
            ? Text(event.eventData?.title ?? 'New Event')
            : null,
      ),
    );
  }

  bool get isMobile {
    return kIsWeb ? false : Platform.isAndroid || Platform.isIOS;
  }

  Widget _scheduleTileBuilder(CalendarEvent<Event> event, DateTime date) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: event.eventData?.color ?? Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                event.eventData?.title ?? 'New Event',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (event.eventData?.employee != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    event.eventData!.employee!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

            if (event.eventData?.date != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    event.eventData!.date!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            if (event.eventData?.title != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    event.eventData!.servises!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _calendarHeader(DateTimeRange dateTimeRange) {
    return Row(
      children: [
        DropdownMenu(
          onSelected: (value) {
            if (value == null) return;
            setState(() {
              currentConfiguration = value;
            });
          },
          initialSelection: currentConfiguration,
          dropdownMenuEntries: viewConfigurations
              .map((e) => DropdownMenuEntry(value: e, label: e.name))
              .toList(),
        ),
        IconButton.filledTonal(
          onPressed: controller.animateToPreviousPage,
          icon: const Icon(Icons.navigate_before_rounded),
        ),
        IconButton.filledTonal(
          onPressed: controller.animateToNextPage,
          icon: const Icon(Icons.navigate_next_rounded),
        ),
        IconButton.filledTonal(
          onPressed: () {
            controller.animateToDate(DateTime.now());
          },
          icon: const Icon(Icons.today),
        ),
      ],
    );
  }
}

class Event {
  /// The title of the [Event].
  final String title;

  /// The description of the [Event].
  final String? servises;

  /// The color of the [Event] tile.
  final Color? color;

  final String employee;

  final String date ;

  final Map<String,dynamic> orderData ;

  Event(
      {required this.title,
      required this.color,
      required this.employee,
      required this.servises ,
      required this.date ,
        required this.orderData
      });
}
