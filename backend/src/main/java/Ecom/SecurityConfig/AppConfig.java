package Ecom.SecurityConfig;

import java.util.Arrays;
import java.util.Collections;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class AppConfig {

        // ====================== 1. Actuator endpoints – completely open
        // ======================
        @Bean
        @Order(1)
        public SecurityFilterChain actuatorSecurityFilterChain(HttpSecurity http) throws Exception {
                http.securityMatcher("/actuator/**")
                                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
                                .csrf(csrf -> csrf.disable())
                                .sessionManagement(session -> session
                                                .sessionCreationPolicy(SessionCreationPolicy.STATELESS));
                return http.build();
        }

        // ====================== 2. Main application security ======================
        @Bean
        @Order(2)
        public SecurityFilterChain mainSecurityFilterChain(HttpSecurity http) throws Exception {
                http
                                .sessionManagement(session -> session
                                                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                                .csrf(csrf -> csrf.disable())
                                .addFilterAfter(new JwtTokenGeneratorFilter(), BasicAuthenticationFilter.class)
                                .addFilterBefore(new JwtTokenValidatorFilter(), BasicAuthenticationFilter.class)
                                .authorizeHttpRequests(auth -> auth
                                                // Public endpoints (excluding actuator – already handled above)
                                                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                                                .requestMatchers(HttpMethod.POST, "/ecom/admin", "/ecom/customers")
                                                .permitAll()
                                                .requestMatchers(HttpMethod.DELETE, "/ecom/orders/users/**").permitAll()
                                                .requestMatchers(HttpMethod.GET, "/ecom/signIn",
                                                                "/ecom/product-reviews/**", "/ecom/products/**")
                                                .permitAll()

                                                // Role-based endpoints
                                                .requestMatchers(HttpMethod.POST, "/ecom/product/**",
                                                                "/ecom/order-shippers/**")
                                                .hasRole("ADMIN")
                                                .requestMatchers(HttpMethod.POST, "/ecom/product/**",
                                                                "/ecom/product-reviews/**",
                                                                "/ecom/customer-addresses/**", "/ecom/cart/**",
                                                                "/ecom/orders/**",
                                                                "/ecom/order-shipping/**")
                                                .hasRole("USER")
                                                .requestMatchers(HttpMethod.PUT, "/ecom/admin/**", "/ecom/products/**")
                                                .hasRole("ADMIN")
                                                .requestMatchers(HttpMethod.PUT, "/ecom/admin/**",
                                                                "/ecom/product-reviews/**",
                                                                "/ecom/customer-addresses/update/**", "/ecom/cart/**",
                                                                "/ecom/order-shipping/**")
                                                .hasRole("USER")
                                                .requestMatchers(HttpMethod.DELETE, "/ecom/products/**",
                                                                "/ecom/product-reviews/**",
                                                                "/ecom/customer-addresses/delete/**",
                                                                "/ecom/order-shipping/**",
                                                                "/ecom/order-shippers/**")
                                                .hasRole("ADMIN")
                                                .requestMatchers(HttpMethod.DELETE, "/ecom/cart/remove-product/**")
                                                .hasRole("USER")
                                                .requestMatchers(HttpMethod.GET, "/ecom/customer-addresses/**",
                                                                "/ecom/cart/products/**",
                                                                "/ecom/orders/**", "/ecom/order-shippers",
                                                                "/ecom/order-payments/**")
                                                .hasAnyRole("ADMIN", "USER")

                                                // All other requests must be authenticated
                                                .anyRequest().authenticated())
                                .httpBasic(Customizer.withDefaults());

                return http.build();
        }

        @Bean
        public PasswordEncoder passwordEncoder() {
                return new BCryptPasswordEncoder();
        }

        @Bean
        public CorsConfigurationSource corsConfigurationSource() {
                CorsConfiguration configuration = new CorsConfiguration();
                configuration.setAllowedOriginPatterns(Arrays.asList(
                                "https://eccomers96.netlify.app",
                                "http://localhost:3000",
                                "http://*.elb.eu-west-1.amazonaws.com", // ADD
                                "http://a9dc8c6a7a3f445b7b6db6a79af040f5-eca087bf6dc40184.elb.eu-west-1.amazonaws.com" // ADD
                ));
                configuration.setAllowedMethods(Collections.singletonList("*"));
                configuration.setAllowedHeaders(Collections.singletonList("*"));
                configuration.setExposedHeaders(Arrays.asList("Authorization"));
                configuration.setAllowCredentials(true);

                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
                source.registerCorsConfiguration("/**", configuration);
                return source;
        }
}