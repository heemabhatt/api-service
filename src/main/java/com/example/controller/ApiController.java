package com.example.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ApiController {

	
	@Value("${spring.myenv}")
	private String myenv;
	
	// run using this command : mvn clean install spring-boot:run -Dspring-boot.run.profiles=Local -DskipTests
	
	@GetMapping("/")
	public String Names()
	{
		return " My Env: " + myenv   ;
	}
}
