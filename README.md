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

- **[Data Augmentation](https://colab.research.google.com/drive/1ruh7C_4Lo50bER6l-NCyHkkfIwyHkGQo?usp=sharing)**: Work has been done on synthesizing data to be used for the machine learning training and testing datasets. The purpose of this was to minimize the challenges we experienced with utilizing the Bar Crawl dataset and processing it for our machine learning model. We eventually switched back to utilizing the existing Bar Crawl dataset instead of synthesizing our own data, so the functions written here were not used/merged with main, and there are no pull requests associated with it due to it being developed via Google Colab. The functions written include several various approaches for processing a CSV input file containing 3D accelerometer data values and generating more data points to artificially increase the size of our mini-dataset created by walking with the app on our own. These approaches include generating random values within the minimum/maximum range of the initial mini-dataset, and generating random values within n standard deviations of the mean. Worked on by Shivani Sista.

- **[REST API](https://github.com/gitasupra/Artera1_AWARE/tree/JL-CS-SS-RestFlask)**: Work has been done on integrating a REST API, potentially unlocking supplementary functionalities such as processing additional data features. A [functional server link](https://jessicalieu.pythonanywhere.com) is currently operational, offering a /uploadCSV endpoint enabling CSV file uploads for server-side processing. Upon processing, the server returns machine learning model predictions in JSON format. The Python code can be found here: https://github.com/jessica-lieu/AWARE-FlaskApp. This method was also intended to be an alternative to modifying the existing Github machine learning model and converting the Python scripts to Swift, however, we did not end up using this REST API approach either because the Python to Swift conversions ended up being successful. Worked on by Jessica Lieu, Cheryl Stanley, and Shivani Sista.
  

---

AWARE is sponsored by Artera, with Anav Sangvi as our mentor and Maren Rey providing design feedback

**Note**: AWARE is intended for informational purposes only and should not be relied upon as a sole determinant of intoxication level. Always make responsible decisions regarding alcohol consumption.


l
