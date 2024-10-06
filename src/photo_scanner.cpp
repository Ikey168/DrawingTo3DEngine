#include <opencv2/opencv.hpp>
#include <iostream>

class ShapeCornerDetector {
public:
    // Constructor
    ShapeCornerDetector(const std::string& imagePath) {
        // Load the image
        image = cv::imread(imagePath, cv::IMREAD_COLOR);
        if (image.empty()) {
            std::cerr << "Error: Could not load image!" << std::endl;
            exit(1);
        }
    }

    // Method to detect and return corner points
    std::vector<cv::Point> detectCorners() {
        // Convert image to grayscale
        cv::Mat gray;
        cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);

        // Apply GaussianBlur to smooth the image and reduce noise
        cv::GaussianBlur(gray, gray, cv::Size(5, 5), 2);

        // Edge detection using Canny
        cv::Mat edges;
        cv::Canny(gray, edges, 50, 150, 3);

        // Find contours from edges
        std::vector<std::vector<cv::Point>> contours;
        cv::findContours(edges, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

        // Approximate the contour to a polygon and get its corners
        std::vector<cv::Point> approxCorners;
        for (const auto& contour : contours) {
            double peri = cv::arcLength(contour, true);
            std::vector<cv::Point> approx;
            cv::approxPolyDP(contour, approx, 0.02 * peri, true);

            if (approx.size() >= 3) {  // A valid shape should have at least 3 corners
                approxCorners = approx;
                break;  // We assume only one shape in the image
            }
        }

        // Draw detected corners on the original image (for visualization)
        drawCorners(approxCorners);

        // Return the corners
        return approxCorners;
    }

    // Method to display the image with corners drawn
    void displayImage() const {
        cv::imshow("Detected Corners", image);
        cv::waitKey(0);  // Wait for a key press to close the window
    }

private:
    cv::Mat image;  // The original image

    // Helper function to draw corners on the image
    void drawCorners(const std::vector<cv::Point>& corners) {
        for (const auto& corner : corners) {
            cv::circle(image, corner, 5, cv::Scalar(0, 0, 255), -1);  // Red dots for corners
        }
    }
};

// Main function to use the class
int main(int argc, char** argv) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <image_path>" << std::endl;
        return -1;
    }

    // Create the detector and detect corners
    ShapeCornerDetector detector(argv[1]);
    std::vector<cv::Point> corners = detector.detectCorners();

    // Print the detected corner coordinates
    std::cout << "Detected corners:" << std::endl;
    for (const auto& corner : corners) {
        std::cout << "(" << corner.x << ", " << corner.y << ")" << std::endl;
    }

    // Display the image with corners
    detector.displayImage();

    return 0;
}