Chat obsługuje jedynie rozmowy między dwoma użytkownikami. Do odpalenia modułu chatu w swoim projekcie potrzebujesz skonfigurować u siebie SDK https://firebase.google.com/docs/ios/setup. 
Następnie skopiuj sobie projekt z repozytorium: https://git.applover.pl/FirebaseChat/iOS.git. Do swojego projektu przekopiuj wszystkie pliki z folderu ChatModule. Całość składa się z 5 grup i 1 pliku storyboard.
Następnie skonfiguruj SKD dla funkcji firebase według tego poradnika: https://firebase.google.com/docs/functions/get-started. Wykonaj jedynie kroki z sekcji Set up and initialize Firebase SDK for Cloud Functions. 
Gdy numer 3 przebiegł pomyślnie i możesz logować się za pomocą komendy firebase login znaczy to, ze jesteś gotowy na ten etap. Teraz skopiuj projekt funkcji z repozytorium: https://git.applover.pl/FirebaseChat/functions.git. Następnie wejdź w folder firebase i zweryfikuj komendą firebase use czy masz aktywny właściwy projekt, jeżeli nie to go aktywuj poprzez firebase user nazwa_projektu.
Skonfiguruj teraz pola, które ma posiadać model chat usera. Otwórz plik config.js i ustaw ścieżkę do modelu usera a następnie podaj nazwę wymaganego pola NAME_KEY, reszta jest opcjonalna.
Użyj komendy firebase deploy —only functions. Jeżeli wszystko przebiegło pomyślnie, moduł został pomyślnie wgrany.

Od teraz po każdej pomyślnej rejestracji oprócz Twojego modelu usera tworzy się automatycznie model chat usera z takim samym UID. W swoim projekcie musisz pamiętać aby w jakimś miejscu (najlepiej podczas logowania) zaciągnąć obiekt ChatUser z bazy zapytaniem poniżej, a następnie wpisać go pod zmienną ChatUser.currentUser

	ChatUser.fetch(withId uid: String, 
			completionHandler: @escaping (Result<ChatUser>) -> Void)

Nowe kanały tworzy się zapytaniem:
 	Channel.create(withName: String, 
			users: [ChatUser] = [], 
			completionHandler: @escaping (Result<Channel>) -> Void)