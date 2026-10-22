package com.hobbypath.core.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME_NAME = "Bearer Authentication";

    @Bean
    public OpenAPI hobbyPathOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("HobbyPath API")
                        .description("Hobiler üzerinden insanları ve toplulukları bir araya getiren mobil sosyal platform backend REST API.")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Nevin Malkoç")
                                .email("nevin@hobbypath.com")
                                .url("https://github.com/nevinmalkoc/hobbypath"))
                        .license(new License().name("MIT License")))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME, new SecurityScheme()
                                .name(SECURITY_SCHEME_NAME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("JWT Token'ınızı buraya girin (Örn: 'eyJhbGciOiJIUzI1NiJ9...'). İsteklere 'Authorization: Bearer <token>' olarak eklenecektir.")));
    }
}
