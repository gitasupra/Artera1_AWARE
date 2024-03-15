# AWARE (Apple Watch Alcohol Risk Estimator)

AWARE is an iOS App and Watch App designed to help users track their intoxication level using data from their Apple devices. By analyzing walking steadiness from the phone app and heart rate from the watch app, AWARE provides an estimation of intoxication level to help users make informed decisions about their alcohol consumption.

## Features

- **Detection**: AWARE collects biometric data such as heart rate and walking steadiness from the Apple Watch and iPhone to assess the user's intoxication level.

- **Analysis**: Utilizing real-time machine learning algorithms, AWARE analyzes the collected biometric data to provide users with predictions of their current level of intoxication.

- **Action**: In the interest of user safety, AWARE offers the functionality to automatically send the user's location to designated contacts and emergency medical services (EMS) based on their intoxication level, providing timely assistance if needed.

## Members

- **Shivani Sista**: `sshivani02`

- **Jessica Nguyen**: `jtmnguyen`

- **Cheryl Stanley**: `cherylstanley`

- **Gita Supramaniam**: `gitasupra`

- **Jessica Lieu**: `jessica-lieu`

- **Ritvi Bhatt**: `ritvibhatt`

## Additional Information

- **[Data Augmentation]()**:

- **[REST API](https://github.com/gitasupra/Artera1_AWARE/tree/JL-CS-SS-RestFlask)**: Work has been done on integrating a REST API, potentially unlocking supplementary functionalities such as processing additional data features. A [functional server link](https://jessicalieu.pythonanywhere.com) is currently operational, offering a /uploadCSV endpoint enabling CSV file uploads for server-side processing. Upon processing, the server returns machine learning model predictions in JSON format. The Python code can be found here: https://github.com/jessica-lieu/AWARE-FlaskApp
  

---

AWARE is sponsored by Artera, with Anav Sangvi as our mentor and Maren Rey providing design feedback

**Note**: AWARE is intended for informational purposes only and should not be relied upon as a sole determinant of intoxication level. Always make responsible decisions regarding alcohol consumption.

