import 'package:event_manager/event/event_data_source.dart';
import 'package:event_manager/event/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'event_detail_view.dart';
import 'event_service.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final eventService = EventService();
  //Danh sách sự kiện
  List<EventModel> items = [];
// Taoj CalendarController để điều khiển SfCalendar
  final calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách sự kiện
    calendarController.view = CalendarView.day;
    loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(al!.appTitle),
        actions: [
          PopupMenuButton<CalendarView>(
            onSelected: (value) => {
              setState(() {
                calendarController.view = value;
              })
            },
            itemBuilder: (context) => CalendarView.values.map((view) {
              return PopupMenuItem(
                value: view,
                child: Text(view.name),
              );
            }).toList(),
            icon: getCalendarViewIcon(calendarController.view!),
          ),
          IconButton(
              onPressed: () {
                calendarController.displayDate = DateTime.now();
              },
              icon: const Icon(Icons.today_outlined)),
          IconButton(
              onPressed: () {
                loadEvents();
              },
              icon: const Icon(Icons.refresh_outlined)),
        ],
      ),
      body: SfCalendar(
        controller: calendarController,
        view: CalendarView.day,
        dataSource: EventDataSource(items),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        // nhấn giữ cell thêm sự kiên
        onLongPress: (details) {
          // Nếu không có sự kiện trong cell
          if (details.targetElement == CalendarElement.calendarCell) {
            // tạo mới một đối tượng sự kiện trong thời gian lịch theo giao diện
            final newEvent = EventModel(
                subject: 'New event',
                startTime: details.date!,
                endTime: details.date!.add(const Duration(hours: 1)));
            print(newEvent);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return EventDetailView(
                event: newEvent,
              );
            })).then((value) async {
              if (value == true) {
                await loadEvents();
              }
            });
          }
        },
        onTap: (details) {
          if (details.targetElement == CalendarElement.appointment) {
            final EventModel event = details.appointments!.first;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return EventDetailView(event: event);
              },
            )).then((value) async {
              if (value == true) {
                await loadEvents();
              }
            });
          }
        },
      ),
    );
  }

  Future<void> loadEvents() async {
    final events = await eventService.getAllEvents();
    setState(() {
      items = events;
    });
  }

  Icon getCalendarViewIcon(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return const Icon(Icons.calendar_today_outlined);
      case CalendarView.week:
        return const Icon(Icons.calendar_view_week_outlined);
      case CalendarView.workWeek:
        return const Icon(Icons.work_history_outlined);
      case CalendarView.month:
        return const Icon(Icons.calendar_view_month_outlined);
      case CalendarView.schedule:
        return const Icon(Icons.schedule_outlined);
      default:
        return const Icon(Icons.calendar_today_outlined);
    }
  }
}
