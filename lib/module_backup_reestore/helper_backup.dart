import 'dart:ffi';

import 'package:flutter/cupertino.dart';

import 'helper_firebase.dart';
import 'helper_toas.dart';
import 'helper_web_service.dart';

class HelperBackUp{


 static Future<Void> backup(String userEmail, String userName)async{
   HelperWebService webService= HelperWebService(userEmail, userName);
   // este metodo hay pasarlo al metodo que hace el backup total por ahora esta aca

   HelperFirebase firebase = HelperFirebase(userEmail, userName, HelperFirebase.capetaFolders);
   // este metodo hay pasarlo al metodo que hace el backup total por ahora esta aca
   await firebase.eliminarArchivosPorUsuario();

    await webService.backUpTraslations();
    HelperToast.showToast("traducciones completadas");
    await webService.backUpRelation();
    HelperToast.showToast("Relations completados");

    await webService.backUpFolders(firebase);
    HelperToast.showToast("folderes completados");
    firebase.tipo=HelperFirebase.carpetaImagenes;
    await webService.backUpImages(firebase);
    HelperToast.showToast("imagenes completados");

    HelperToast.showToast("Termino la subida de Images");
  }

  static void reestore(String userEmailNameToRestore, int selectedFolderToRestore, int selectedLocalFolder){
  HelperWebService webService=HelperWebService(userEmailNameToRestore, "");

  webService.replaceFolder(userEmailNameToRestore, selectedFolderToRestore, selectedLocalFolder);
  }






}