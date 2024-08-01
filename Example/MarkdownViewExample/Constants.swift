//
//  Constants.swift
//  MarkdownViewExample
//
//  Created by Andrew Zheng on 8/1/24.
//

import Foundation

enum Constants {}

extension Constants {
    static let californiaPopulation = #"""
    Here’s a table showing California’s population over the last five years. The data is hypothetical and used for illustration:

    | Year | Population (millions) |
    |------|-----------------------|
    | 2019 | 39.50                 |
    | 2020 | 39.24                 |
    | 2021 | 39.14                 |
    | 2022 | 39.10                 |
    | 2023 | 39.00                 |

    ### Line of Best Fit Using Least Squares

    To find the line of best fit using the least squares method, we can use the formula for the line:

    \[ y = mx + b \]

    where:
    - \( y \) is the population
    - \( x \) is the year
    - \( m \) is the slope of the line
    - \( b \) is the y-intercept

    #### Step-by-step Calculation

    1. **Convert Years**: To simplify calculations, let's convert the years to \( x \) values. Let \( x = 0 \) correspond to 2019.

        | \( x \) | Year | Population (y) |
        |---------|------|-----------------|
        | 0       | 2019 | 39.50           |
        | 1       | 2020 | 39.24           |
        | 2       | 2021 | 39.14           |
        | 3       | 2022 | 39.10           |
        | 4       | 2023 | 39.00           |

    2. **Calculate the Means**:

       \[
       \bar{x} = \frac{0 + 1 + 2 + 3 + 4}{5} = 2
       \]

       \[
       \bar{y} = \frac{39.50 + 39.24 + 39.14 + 39.10 + 39.00}{5} = 39.196
       \]

    3. **Calculate the Slope (\( m \))**:

       \[
       m = \frac{\sum{(x_i - \bar{x})(y_i - \bar{y})}}{\sum{(x_i - \bar{x})^2}}
       \]

       \[
       m = \frac{(0-2)(39.50-39.196) + (1-2)(39.24-39.196) + (2-2)(39.14-39.196) + (3-2)(39.10-39.196) + (4-2)(39.00-39.196)}{(0-2)^2 + (1-2)^2 + (2-2)^2 + (3-2)^2 + (4-2)^2}
       \]

       \[
       m = \frac{(-2 \times 0.304) + (-1 \times 0.044) + (0 \times -0.056) + (1 \times -0.096) + (2 \times -0.196)}{4 + 1 + 0 + 1 + 4}
       \]

       \[
       m = \frac{-0.608 - 0.044 + 0 - 0.096 - 0.392}{10}
       \]

       \[
       m = \frac{-1.14}{10} = -0.114
       \]

    4. **Calculate the Y-intercept (\( b \))**:

       \[
       b = \bar{y} - m\bar{x}
       \]

       \[
       b = 39.196 - (-0.114 \times 2)
       \]

       \[
       b = 39.196 + 0.228 = 39.424
       \]

    5. **Equation of the Line of Best Fit**:

       \[
       y = -0.114x + 39.424
       \]

    ### Interpretation

    The line of best fit is \( y = -0.114x + 39.424 \). This equation suggests that the population of California has been decreasing by approximately 0.114 million people per year over the last five years.

    ### Conclusion

    By applying the least squares method, we derived a trend line that estimates the decline in population over the given period. This analysis helps understand the general trend and make projections for future population changes.
    """#
}
