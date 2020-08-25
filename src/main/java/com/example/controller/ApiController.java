package com.example.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ApiController {

	
	@Value("${spring.myenv}")
	private String myenv;
	
	 @Value("${ENVIRONMENT_MESSAGE}")
	 private String env_msg;
	// run using this command : mvn clean install spring-boot:run -Dspring-boot.run.profiles=Local -DskipTests
	
	@GetMapping("/")
	public String Names()
	{
		return "1*** My Environment From Active Profile: " + myenv  + " *** Environment Message From Config File: "+ env_msg + " ***";
	}
}
