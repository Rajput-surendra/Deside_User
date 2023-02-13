
import 'dart:convert';
import 'dart:io';

import 'package:entemarket_user/Helper/Constant.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/Color.dart';
import '../Helper/String.dart';
class CustomOrder extends StatefulWidget {
  const CustomOrder({Key? key}) : super(key: key);

  @override
  State<CustomOrder> createState() => _CustomOrderState();
}



class _CustomOrderState extends State<CustomOrder> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController imagesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  var filesPath;
  String? fileName;
  String? resumeData;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    setState(() {
      filesPath = result.files.first.path ?? "";
      fileName = result.files.first.name;
      // reportList.add(result.files.first.path.toString());
      resumeData = null;
    });
  }

  final ImagePicker _picker = ImagePicker();
  File? imageFile;

  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }
  _getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }

  uploadDatahere()async{
    SharedPreferences pref  = await SharedPreferences.getInstance();
    var headers = {
      'Cookie': 'ci_session=d7070140f50ae15f0337322f3fc7851aca358840'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}custom_order'));
    request.fields.addAll({
      'username': nameController.text,
      'email': emailController.text,
      'address': addressController.text,
      'user_id': '${CUR_USERID}',
      'mobile': mobileController.text
    });
   imageFile == null  ? null : request.files.add(await http.MultipartFile.fromPath('img', imageFile!.path.toString()));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final  jsonResponse = json.decode(finalResult);
      print("final respnse here ${jsonResponse}");
      Fluttertoast.showToast(msg: "${jsonResponse['message']}");

    }
    else {
      print(response.reasonPhrase);
    }

  }

  Future<bool> showExitPopup() async {
    return await showDialog( //show confirm dialogue
      //the return value will be from "Yes" or "No" options
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _getFromCamera();
              },
              //return false when click on "NO"
              child:Text('Camera'),
            ),
            SizedBox(height: 15,),
            ElevatedButton(
              onPressed: (){
                _getFromGallery();
                // Navigator.pop(context,true);
                // Navigator.pop(context,true);
              },
              //return true when click on "Yes"
              child:Text('Gallery'),
            ),
          ],
        )
      ),
    )??false; //if showDialouge had returned null, then return false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xffE09D00),
        centerTitle: true,
        title: Text("Custom Order Upload"),
      ),
      body:  Form(
        key: _formKey,
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 32.0),
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.name,
                    validator: (v){
                      if(v!.isEmpty){
                        return "Name is required";
                      }

                    },
                    controller: nameController,decoration: InputDecoration(
                    hintText: "Name ",
                  ),
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    validator: (v){
                      if(v!.isEmpty ){
                        return "Email Id is required";
                      } if(!v.contains('@') ){
                        return "Email Id is required";
                      }
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email Id",
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    validator: (v){
                      if(v!.isEmpty){
                        return "Mobile No is required";
                      }
                      if(v.length != 10){
                        return "Enter 10 digit number";
                      }
                    },
                    controller: mobileController,
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "Mobile",
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                    validator: (v){
                      if(v!.isEmpty){
                        return "Address is required";
                      }
                    },
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: "Address",
                    ),
                  ),
                  SizedBox(height: 10,),
                  // TextFormField(
                  //   validator: (v){
                  //     if(v!.isEmpty){
                  //       return "Query is required";
                  //     }
                  //   },
                  //   controller: queryController,
                  //   decoration: InputDecoration(
                  //     hintText: "Your Query",
                  //   ),
                  // ),
                  // SizedBox(height: 5,),
                ],
              ),
            )
            ,

          imageFile == null ? SizedBox.shrink() :  Container(
              height: 150,
              width: 60,
              margin: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
              child: ClipRRect(
                  borderRadius:BorderRadius.circular(10),
                  child: Image.file(imageFile!,fit: BoxFit.fill,)),
            ),
            InkWell(
              onTap: (){
                showExitPopup();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:Color(0xffE09D00),
                ),
                child: Text("Upload Image",style:TextStyle(color: Colors.white),),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children:
                  [
                    InkWell(
                      onTap: (){
                        if(_formKey.currentState!.validate()){
                          Navigator.pop(context,{
                            'name': nameController.text,
                            'email': emailController.text,
                             'mobile': mobileController.text,
                             'Address': addressController.text,
                             'images': imagesController.text

                          });
                          //franchise();
                          uploadDatahere();
                        }
                        else{
                          Fluttertoast.showToast(msg: "All Fields are required");
                        }

                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffE09D00),
                              borderRadius: BorderRadius.circular(10),

                              border: Border.all(color: Colors.black),

                          ),
                          height: 40,
                          width: 80,
                          child: Center(child: Text('Submit',style: TextStyle(color: Colors.black),)),
                        ),
                      ),
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //
                    //       border: Border.all(color: colors.blackTemp)
                    //   ),
                    //
                    //   height: 40,
                    //   width: 80,
                    //   child: Center(child: Text('Reset',style: TextStyle(color: colors.blackTemp),)),
                    // )
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }


}
