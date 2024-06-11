import 'dart:io';

import 'package:car_spa/widgets/dialog.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

class calenderView extends StatefulWidget {
  const calenderView({super.key});

  @override
  State<calenderView> createState() => _calenderViewState();
}

class _calenderViewState extends State<calenderView> {
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
      name: 'Day',
      numberOfDays: 1,
      startHour: 6,
      endHour: 24,
      createEvents: false,
    ),
    WeekConfiguration(
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
    DateTime now = DateTime.now();
    eventController.addEvents(
        [
          // Day 1
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now(),
              end: DateTime.now().add(const Duration(hours: 1)),
            ),
            eventData: Event(
              title: 'Event 1',
              color: Color(0xFF2ECC71),
              description: 'Dummy description for Event 1',
            ),
          ),
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now().add(const Duration(minutes: 30)),
              end: DateTime.now().add(const Duration(hours: 2)),
            ),
            eventData: Event(
              title: 'Event 2',
              color:  Color(0xFF3498DB),
              description: 'Dummy description for Event 2',
            ),
          ),
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
              end: DateTime.now().add(const Duration(hours: 3)),
            ),
            eventData: Event(
              title: 'Event 3',
              color:Color(0xFFE74C3C),
              description: 'Dummy description for Event 3',
            ),
          ),
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now().add(const Duration(hours: 1, minutes: 45)),
              end: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
            ),
            eventData: Event(
              title: 'Event 4',
              color: Color(0xFFF4D03F),
              description: 'Dummy description for Event 4',
            ),
          ),
          // Day 2
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now().add(const Duration(days: 1)),
              end: DateTime.now().add(const Duration(days: 1, hours: 1)),
            ),
            eventData: Event(
              title: 'Event 5',
              color: Color(0xFF2ECC71),
              description: 'Dummy description for Event 5',
            ),
          ),
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now().add(const Duration(days: 1, minutes: 30)),
              end: DateTime.now().add(const Duration(days: 1, hours: 2)),
            ),
            eventData: Event(
              title: 'Event 6',
              color:  Color(0xFF3498DB),
              description: 'Dummy description for Event 6',
            ),
          ),
          // Add more events for Day 2 here


          // Day 1
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now(),
              end: DateTime.now().add(const Duration(hours: 1 , days: 5)),
            ),
            eventData: Event(
              title: 'Event 1',
              color: Color(0xFF2ECC71),
              description: 'Dummy description for Event 1',
            ),
          ),
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now().add(const Duration(minutes: 30, days: 5)),
              end: DateTime.now().add(const Duration(hours: 2, days: 5)),
            ),
            eventData: Event(
              title: 'Event 2',
              color:  Color(0xFF3498DB),
              description: 'Dummy description for Event 2',
            ),
          ),
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now().add(const Duration(hours: 1, minutes: 30, days: 5)),
              end: DateTime.now().add(const Duration(hours: 3, days: 5)),
            ),
            eventData: Event(
              title: 'Event 3',
              color:Color(0xFFE74C3C),
              description: 'Dummy description for Event 3',
            ),
          ),
          CalendarEvent(
            modifiable: false,
            dateTimeRange: DateTimeRange(
              start: DateTime.now().add(const Duration(hours: 1, minutes: 45, days: 5)),
              end: DateTime.now().add(const Duration(hours: 3, minutes: 30, days: 5)),
            ),
            eventData: Event(
              title: 'Event 4',
              color: Color(0xFFF4D03F),
              description: 'Dummy description for Event 4',
            ),
          ),

          // Continue for Day 3, Day 4, etc.
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendar = CalendarView<Event>(
      style: CalendarStyle(
          backgroundColor: Colors.black,
          calendarHeaderBackgroundStyle: CalendarHeaderBackgroundStyle(
              headerBackgroundColor: Colors.white)
      ),
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

  Future<void> _onEventTapped(
    CalendarEvent<Event> event,
  ) async {
    print(event.eventData!.title.toString());
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
            if (event.eventData?.description != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    event.eventData!.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            if (event.eventData?.title != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    event.eventData!.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
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
  Event(
      {required this.title,
      this.description="xxx",
      this.color = Colors.black,
      });

  /// The title of the [Event].
  final String title;

  /// The description of the [Event].
  final String? description;

  /// The color of the [Event] tile.
  final Color? color;

  // /// this is the discritpoipmn
  // final String? subTitle;
  //
  // final String? url;
}
