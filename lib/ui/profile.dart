import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/ui/AppColors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_shop/ui/login_screen.dart'; // Import the fluttertoast package

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  TextEditingController? _ageController;

  setDataToTextField(data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Update Your Profile Information",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController =
              TextEditingController(text: data['name']),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.person,
              color: AppColors.deep_blue,
            ),
            hintText: 'Your name',
            labelText: 'Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _phoneController =
              TextEditingController(text: data['phone']),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.phone,
              color: AppColors.deep_blue,
            ),
            hintText: 'Your phone number',
            labelText: 'Phone Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _ageController = TextEditingController(text: data['age']),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.calendar_today,
              color: AppColors.deep_blue,
            ),
            hintText: 'Your age',
            labelText: 'Age',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => updateData(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: AppColors.deep_blue,
              padding: const EdgeInsets.all(15.0),
            ),
            child: const Text(
              "Update",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              print("Logout");
              FirebaseAuth.instance.signOut();
              Get.offAll(() => const LoginScreen());
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: AppColors.deep_blue,
              padding: const EdgeInsets.all(15.0),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  updateData() {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("users-form-data");
    return collectionRef.doc(FirebaseAuth.instance.currentUser!.email).update({
      "name": _nameController!.text,
      "phone": _phoneController!.text,
      "age": _ageController!.text,
    }).then((value) {
      Fluttertoast.showToast(
          msg: "Updated Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0);
    }).catchError((error) {
      Fluttertoast.showToast(
          msg: "Failed to update: $error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users-form-data")
                .doc(FirebaseAuth.instance.currentUser!.email)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              var data = snapshot.data;
              if (data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return setDataToTextField(data);
            },
          ),
        ),
      ),
    );
  }
}
