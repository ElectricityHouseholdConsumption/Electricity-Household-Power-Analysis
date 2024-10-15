# Electricity Consumption Analysis in an Israeli Household

## 🏠 Project Overview

This project analyzes electricity consumption in a household of four (two adults and two children) located in Israel. The primary objectives are to:

- Understand patterns of energy usage
- Identify potential areas for efficiency improvements
- Provide insights to reduce overall electricity consumption

## 📊 Dataset

### Description

- **Time Period:** [Specify period, e.g., 1 year, 6 months]
- **Frequency:** Hourly/Daily/Monthly electricity usage data

### Columns

| Column Name | Description |
|-------------|-------------|
| Timestamp | Date and time of the recorded consumption |
| Electricity_Consumption_kWh | Amount of electricity consumed in kilowatt-hours |
| Temperature | External temperature readings (if applicable) |
| Appliance_Usage | Information on the usage of major appliances (if tracked) |
| Family_Activity | Notes on family activities or routines that may influence consumption (optional) |

### Data Source

The data was collected using smart meters installed in the household, provided by Israel Electric Corporation.

## 🔍 Analysis

### Goals

1. Analyze daily, weekly, and monthly electricity consumption patterns
2. Identify peak consumption periods and correlate them with household activities or external factors
3. Compare electricity consumption on weekdays versus weekends
4. Suggest methods to optimize electricity use and reduce costs based on the analysis

### Methodology

1. **Data Cleaning:** Handle missing or inconsistent data, format timestamps, ensure unit consistency
2. **Exploratory Data Analysis (EDA):** Visualize data to identify trends and patterns
3. **Feature Engineering:** Create new features (e.g., average daily consumption, peak hour usage)
4. **Modeling (optional):** Use predictive modeling to forecast future consumption or simulate behavioral changes
5. **Reporting:** Compile findings into a comprehensive report with visualizations and actionable insights

## 🛠️ Tools & Technologies

- **Programming Language:** SQL 
- **Libraries:** Pandas, NumPy, Matplotlib, Seaborn, Scikit-learn (for modeling)
- **Data Visualization:** Power BI/Tableau/Matplotlib
- **Database:** SQL Server (if applicable)

## 📦 Installation

To replicate this analysis, ensure you have the following dependencies installed:

```bash
pip install pandas numpy matplotlib seaborn scikit-learn
```

## 🚀 Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/electricity-consumption-analysis.git
   ```

2. Navigate to the project directory:
   ```bash
   cd electricity-consumption-analysis
   ```

3. Run the analysis script:
   ```bash
   python analysis.py
   ```

## 📈 Results

The results of the analysis can be found in the `results` directory, including:
- Visualizations of consumption patterns
- A detailed report with insights and recommendations

## 🎯 Conclusion

This project provides valuable insights into electricity consumption in a typical Israeli household, highlighting areas for potential savings and efficiency improvements.

## 🔮 Future Work

- Extend the analysis to include more households for a broader perspective
- Incorporate additional external factors such as weather conditions, electricity prices, or seasonal changes

## 👥 Contributors

- Inbar Liraz & David Porat

