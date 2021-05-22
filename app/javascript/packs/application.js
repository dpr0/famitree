import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import firebase from 'firebase/app';
import "@fortawesome/fontawesome-free/js/all";
require("firebase");
require("firebaseui-ru");
require('admin-lte');
require('d3');

Rails.start();
ActiveStorage.start();

var config = {
    apiKey: "AIzaSyBs8Vz7NmleSQpPrt0sOIrK9kOjcndgda8",
    authDomain: "familytree-3ccbc.firebaseapp.com",
    projectId: "familytree-3ccbc",
    storageBucket: "familytree-3ccbc.appspot.com",
    messagingSenderId: "145555995263",
    appId: "1:145555995263:web:f8360e36c5e501bce65d4a",
    measurementId: "G-MHPDCERQDW"
    // apiKey: "AIzaSyAa9v2fyoyUP7h0QmYuYvTaAhEGlNv0WaE",
    // authDomain: "famitree-cc4ba.firebaseapp.com",
    // projectId: "famitree-cc4ba",
    // storageBucket: "famitree-cc4ba.appspot.com",
    // messagingSenderId: "331286688493",
    // appId: "1:331286688493:web:26e1267f63f978a09dd2e4"
};
firebase.initializeApp(config);
firebase.analytics();

var ui = new firebaseui.auth.AuthUI(firebase.auth());
ui.start('#firebaseui-auth-container', {
    signInOptions: [
        {provider: firebase.auth.PhoneAuthProvider.PROVIDER_ID, defaultCountry: 'ru'},
        firebase.auth.GoogleAuthProvider.PROVIDER_ID
    ],
    callbacks: {
        signInSuccessWithAuthResult: (currentUser) => {
            $.post('/users/auth/firebase/callback', {
                    authenticity_token: $('meta[name="csrf-token"]').attr("content"),
                    user: {
                        provider: currentUser.additionalUserInfo.providerId,
                        uid: currentUser.user.uid,
                        email: currentUser.user.email,
                        name: currentUser.user.displayName,
                        phone: currentUser.user.phoneNumber
                    }
                },
                () => window.location.reload()
            );
            return false;
        }
    },
    credentialHelper: firebaseui.auth.CredentialHelper.GOOGLE_YOLO
});

console.log(process)
// $( () => $('[data-toggle="tooltip"]').tooltip() );
