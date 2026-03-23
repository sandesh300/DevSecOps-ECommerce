package Ecom.SecurityConfig;

public interface SecurityConstants {
    // Read from environment variable injected by K8s secret
    public static final String JWT_KEY = System.getenv("JWT_SECRET") != null 
        ? System.getenv("JWT_SECRET") 
        : "secretsfhsfjhdkjngdfjkgfgjdlkfjsdkfjsd";
    public static final String JWT_HEADER = "Authorization";
}