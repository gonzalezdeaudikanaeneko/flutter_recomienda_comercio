import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';
import 'package:recomienda_flutter/cloud/todos_establecimientos.dart';
import 'package:recomienda_flutter/model/booking_model.dart';
import 'package:recomienda_flutter/model/funcion.dart';
import 'package:recomienda_flutter/model/servicios.dart';
import 'package:recomienda_flutter/screens/InicioEstablecimiento.dart';
import 'package:recomienda_flutter/utils/utils.dart';
import 'package:recomienda_flutter/widgets/notification_widget.dart';
import '../model/establecimientos.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_widgets.dart';
import 'model/salones.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'model/usuarios.dart';

class BookingEstablecimientoScreen extends StatefulWidget{
  const BookingEstablecimientoScreen({Key? key}) : super(key: key);

  @override
  _BookingEstablecimientoScreen createState() => new _BookingEstablecimientoScreen();

}

class _BookingEstablecimientoScreen extends State<BookingEstablecimientoScreen> {

  String emailUser = FirebaseAuth.instance.currentUser?.email as String;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  int currentStep = 1;
  Establecimientos selectedEstablecimiento = Establecimientos(name: '', address: '', imagen: '');
  Salon selectedSalon = Salon(name: '', address: '', horario: '', docId: '');
  Servicios selectedServicio = Servicios(name: '', userName: '', docId: '');
  Funcion selectedFuncion = Funcion(name: '', slot: 0, docId: '');
  DateTime selectedDate = DateTime.now();
  String selectedTime = '';
  int selectedTimeSlot = -1;

  @override
  void initState(){
    super.initState();
    NotificationWidget.init();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          key: scaffoldKey,
            appBar: AppBar(
                title: Text('Reservar'),
                centerTitle: true,
                backgroundColor: Colors.black45,
                leading: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7CBF97),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => InicioEstablecimiento(),
                      ),
                    );
                  },
                  child: Icon(Icons.arrow_back, color: Colors.white),
                )
            ),
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 150,),
              NumberStepper(
                stepRadius: 14,
                activeStep: currentStep - 1,
                direction: Axis.horizontal,
                lineLength: (MediaQuery.of(context).size.width)/15,
                scrollingDisabled: true,
                enableNextPreviousButtons: false,
                enableStepTapping: false,
                numbers: [1, 2, 3],
                stepColor: Color(0xFF669478),
                activeStepColor: Colors.grey,
                numberStyle: TextStyle(color: Colors.white),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 150,),
              Expanded(
                flex: 10,
                child: currentStep == 1
                    ? displayFunciones()
                    : currentStep == 2
                    ? displayTimeSlot(context, selectedFuncion)
                    : currentStep == 3
                    ? displayBookInfo(context)
                    : Container(),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      padding: EdgeInsets.all(8),
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF7CBF97),
                                ),
                                onPressed: currentStep == 1 ? null : () => setState(() => currentStep -= 1),
                                child: Text('Atras',),
                              )
                          ),
                          SizedBox(width: 30,),
                          Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF7CBF97),
                                ),
                                onPressed: (currentStep == 1 &&
                                        selectedFuncion.docId == '') ||
                                    (currentStep == 2 &&
                                        selectedTimeSlot == -1)
                                    ? null
                                    : currentStep == 3
                                    ? null
                                    : () => setState(() => currentStep += 1),
                                child: Text('Siguiente'),
                              )
                          ),
                        ],
                      )),
                ),
              )
            ],
          ),
        )
    );
  }

  displayFunciones() {
    return FutureBuilder(
        //future: getReda('RUU7mpPeTbrhIy2LXtDe'),//ID reda
        future: getReda('uQuBcFe1dvHiSvK9lK85'),//ID reda
        builder: (context, AsyncSnapshot<Salon> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else{
            Salon reda = snapshot.data as Salon;
            return FutureBuilder(
                future: getFunciones(reda),
                builder: (context, AsyncSnapshot<List<Funcion>> snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else{
                    var funciones = snapshot.data as List<Funcion>;
                    if(funciones == null || funciones.length == 0) {
                      return Center(child: CircularProgressIndicator(),);
                    } else
                      return ListView.builder(
                          itemCount: funciones.length,
                          itemBuilder: (context, index){
                            return GestureDetector(
                              onTap: () =>  {
                                setState(() => selectedFuncion = funciones[index]),
                                setState(() => currentStep += 1)
                              },
                              child: Card(
                                color: Color(0xFF7CBF97),
                                child: ListTile(
                                    leading: Icon(
                                      Icons.cut,
                                      color: Colors.black,
                                    ),
                                    trailing: selectedFuncion.docId ==
                                        funciones[index].docId
                                        ? Icon(Icons.check)
                                        : null,
                                    title: Text(
                                      //'${funciones[index].name} (${funciones[index].slot})',
                                      '${funciones[index].name} (${15 * funciones[index].slot} min)',
                                    )
                                ),
                              ),
                            );
                          }
                      );
                  }
                }
            );
          }
        }
    );
  }

  displayTimeSlot(BuildContext context, Funcion fun) {
    var now = selectedDate;
    return Column(
      children: [
        Container(
          color: Color(0xFF7CBF97),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text('${DateFormat.EEEE().format(now)}', style: TextStyle(color: Colors.white)),
                          Text('${now.day}', style: TextStyle(color: Colors.white)),
                          Text('${DateFormat.MMMM().format(now)}', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  )
              ),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.now(), //Tiempo desde que puedo coger cita
                      maxTime: DateTime.now().add(Duration(days: 31)) , //Tiempo hasta qu puedo coger cita
                      onConfirm: (date) => setState(() => selectedDate = date)// next time 31 days ago
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.calendar_today, color: Colors.white,),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height / 150,),
        Expanded(
          child: FutureBuilder(
              //future: getReda('RUU7mpPeTbrhIy2LXtDe'),//ID reda
              future: getReda('uQuBcFe1dvHiSvK9lK85'),//ID reda
              builder: (context, AsyncSnapshot<Salon> snapshot){
                if(snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                else{
                  Salon x = snapshot.data as Salon;
                  return FutureBuilder(
                      //future: getServicio('1ShJfG667NcT0V8A5Xfy'),
                      future: getServicio('FNuMR0BfOBB9OET2akhd'),
                      builder: (context, AsyncSnapshot<Servicios> snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting)
                          return Center(child: CircularProgressIndicator());
                        else{
                          Servicios peluqueria = snapshot.data as Servicios;
                          return FutureBuilder(
                              future: getMaxAvailableTimeSlot(selectedDate),
                              builder: (context, snapshot) {
                                if(snapshot.connectionState == ConnectionState.waiting)
                                  return Center(child: CircularProgressIndicator(),);
                                else
                                {
                                  var maxTimeSlot = snapshot.data as int;
                                  return FutureBuilder(
                                    future: getTimeSlotOfServicios(peluqueria, DateFormat('dd_MM_yy').format(selectedDate), fun),
                                    builder: (context, snapshot) {
                                      if(snapshot.connectionState == ConnectionState.waiting)
                                        return Center(child: CircularProgressIndicator(),);
                                      else{
                                        var listTimeSlot = snapshot.data as List<int>;
                                        return GridView.builder(
                                            itemCount: x.horario.split(',').length,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                childAspectRatio: 1.5,
                                                mainAxisSpacing: 1,
                                                crossAxisSpacing: 2
                                            ),
                                            itemBuilder: (context,index) => GestureDetector(
                                              onTap: maxTimeSlot > index || listTimeSlot.contains(index) ? null : () {
                                                setState(() => selectedTime = x.horario.split(',').elementAt(index));
                                                setState(() => selectedTimeSlot = index);
                                                setState(() => currentStep += 1);
                                              },
                                              child: Card(
                                                shape: BeveledRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                color: listTimeSlot.contains(index)
                                                    ? Color(0xFFBE4A4A)
                                                    : maxTimeSlot > index
                                                    ? Color(0xFFEE5E5E)
                                                    : selectedTime == x.horario.split(',').elementAt(index)
                                                    ? Colors.white12
                                                    : Color(0xFF555555),
                                                child: GridTile(
                                                  child: Center(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text('${x.horario.split(',').elementAt(index).substring(0, 5)}', style: TextStyle(color: Colors.white)),
                                                        Text(listTimeSlot.contains(index) ? 'Lleno'
                                                            : maxTimeSlot > index ? 'No Disponible'
                                                            : 'Disponible', style: TextStyle(color: Colors.white))
                                                      ],
                                                    ),
                                                  ),
                                                  header: selectedTime == x.horario.split(',').elementAt(index) ? Icon(Icons.check) : null,
                                                ),
                                              ),
                                            ));
                                      }
                                    },
                                  );
                                }
                              }
                          );
                        }
                      }
                  );
                }
              }
          )
        ),
      ],
    );
  }

  displayBookInfo(BuildContext context){

    TextEditingController nombreControlador = TextEditingController();
    TextEditingController telefonoControlador = TextEditingController();
    var batch = FirebaseFirestore.instance.batch();
    // /establecimientos/reda/Branch/RUU7mpPeTbrhIy2LXtDe/barber/1ShJfG667NcT0V8A5Xfy
    CollectionReference coleccion = FirebaseFirestore
        .instance
        .collection('establecimientos')
        .doc('reda')
        .collection('Branch')
        .doc('uQuBcFe1dvHiSvK9lK85')
        .collection('barber')
        .doc('FNuMR0BfOBB9OET2akhd')
        .collection(DateFormat('dd_MM_yy').format(selectedDate));

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 30, end: 30),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  labelText: 'Nombre',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle()
              ),
              controller: nombreControlador,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 30, end: 30),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  labelText: 'Telefono',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle()
              ),
              controller: telefonoControlador,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.zero,
              child: FFButtonWidget(
                onPressed: () {

                  BookingModel book = BookingModel(
                    customerEmail: nombreControlador.text,
                    customerName: telefonoControlador.text,
                    done: false,
                    duration: selectedFuncion.slot * 15,
                    establecimiento: '',
                    salonAddress: '',
                    salonId: '',
                    salonName: '',
                    servicioId: '',
                    servicioName: '',
                    slot: selectedTimeSlot,
                    time: '${selectedTime.substring(0,5)} - ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                    timeStamp: DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.length <= 10 ?
                          int.parse(selectedTime.split(':')[0].substring(0,1)) :
                          int.parse(selectedTime.split(':')[0].substring(0,2)),
                        selectedTime.length <= 10 ?
                          int.parse(selectedTime.split(':')[1].substring(0,1)) : //hora
                          int.parse(selectedTime.split(':')[1].substring(0,2))
                    ).millisecondsSinceEpoch
                  );

                  for(var i = 0; i < selectedFuncion.slot; i++){
                    DocumentReference booking = coleccion.doc((selectedTimeSlot + i).toString());
                    batch.set(booking, book.toJson());
                  }

                  batch.commit().then((value) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => InicioEstablecimiento(),
                        )
                    );
                    NotificationWidget.showNotification(
                      title:  'Reserva Guardada',
                      body: 'Dia: ${selectedDate.toString()}',
                    );
                  });
                },
                text: 'REGISTRAR',
                options: FFButtonOptions(
                  width: 150,
                  height: 50,
                  color: Color(0xFF506F52),
                  textStyle:
                  FlutterFlowTheme.of(context).subtitle2.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

}


