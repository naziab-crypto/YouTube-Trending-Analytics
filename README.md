YouTube Trending Videos Analytics & Performance Forecasting

## 📌 Project Overview

This project analyzes YouTube trending video data across multiple countries to understand the factors associated with video performance and trending behavior.

The analysis focuses on content categories, channels, countries, publishing time, engagement, titles, tags, and time-to-trend.

A rule-based performance forecasting framework is also used to estimate potential view ranges and engagement levels for new video content using historical performance benchmarks.

---

## 🎯 Business Objective

The objective of this project is to help digital marketing agencies and content creators:

- Understand YouTube trending patterns
- Identify high-performing content categories
- Compare performance across countries
- Analyze engagement levels
- Identify effective publishing times
- Evaluate title and tag characteristics
- Analyze time-to-trend
- Support data-driven content strategy
- Estimate potential performance before publication

---

## 🛠️ Tools & Technologies

- Microsoft Excel
- PostgreSQL
- SQL
- Power BI
- DAX
- Power Query
- JSON
- Exploratory Data Analysis (EDA)
- Data Visualization
- Business Intelligence

---

## 🔄 Project Workflow

### 1. Excel – Data Cleaning & Preparation

- Cleaned country-wise YouTube trending datasets
- Corrected date formats
- Handled missing values
- Combined multiple country datasets
- Flattened JSON category mappings
- Added country codes
- Created calculated fields such as:
  - Engagement Rate
  - Like Ratio
  - Title Length
  - Tag Count
  - Time-to-Trend

### 2. PostgreSQL – Data Modeling & Analysis

Created a normalized database structure containing:

- Videos
- Categories
- Channels
- Countries
- Staging data

Performed **30+ analytical SQL queries** to analyze:

- Category performance
- Channel performance
- Country-wise trends
- Views and engagement
- Publishing time
- Tags
- Time-to-trend

SQL views were also created for reusable analysis.

### 3. Power BI – Dashboard Development

Developed a **7-page interactive Power BI dashboard**:

1. KPI Overview
2. Category & Content Analysis
3. Channel Performance
4. Country Comparison
5. Time-to-Trend & Publish Timing
6. Tags & Titles Optimization
7. Performance Forecasting

Key measures included:

- Total Views
- Total Likes
- Total Comments
- Total Videos
- Average Views
- Average Engagement Rate
- Average Like Ratio
- Average Time-to-Trend
- Trending Records
- Unique Trending Videos

---

## 🌍 Dataset

The project uses YouTube trending-video data from multiple countries, including:

🇺🇸 US | 🇬🇧 GB | 🇨🇦 CA | 🇩🇪 DE | 🇫🇷 FR | 🇷🇺 RU | 🇲🇽 MX | 🇰🇷 KR | 🇯🇵 JP | 🇮🇳 IN

The source data contains CSV files containing video-level trending information and JSON files containing category mappings.

---

## 📈 Performance Forecasting

A rule-based framework uses historical benchmarks such as:

- Category reach
- Category engagement
- Region
- Posting-time fit
- Tag-count fit

The framework provides an estimated performance range for planning purposes rather than guaranteeing future video performance.

---

## 💡 Business Insights

The analysis supports:

- Data-driven posting strategies
- Category performance benchmarking
- Regional content comparison
- Engagement benchmarking
- Title and tag optimization
- Channel performance analysis
- Pre-publication performance estimation

---

## 📂 Repository Structure

```text
YouTube-Trending-Analytics/
│
├── README.md
├── SQL/
├── Excel/
├── PowerBI/
├── Reports/
└── Images/
