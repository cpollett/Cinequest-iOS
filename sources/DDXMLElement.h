//
//  DDXMLElement.h
//  Cinequest
//
//  Created by Luca Severini on 12/2/13.
//  Copyright (c) 2013 San Jose State University. All rights reserved.
//

#import "DDXMLNode.h"


@interface DDXMLElement : DDXMLNode

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name URI:(NSString *)URI;
- (id)initWithName:(NSString *)name stringValue:(NSString *)string;
- (id)initWithXMLString:(NSString *)string error:(NSError **)error;

#pragma mark - Elements by name ---

- (NSArray *)elementsForName:(NSString *)name;
- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI;

#pragma mark - Attributes ---

- (void)addAttribute:(DDXMLNode *)attribute;
- (void)removeAttributeForName:(NSString *)name;
- (void)setAttributes:(NSArray *)attributes;
- (NSArray *)attributes;
- (NSDictionary*) attributesAsDictionary;
- (DDXMLNode *)attributeForName:(NSString *)name;

#pragma mark - Namespaces ---

- (void)addNamespace:(DDXMLNode *)aNamespace;
- (void)removeNamespaceForPrefix:(NSString *)name;
- (void)setNamespaces:(NSArray *)namespaces;
- (NSArray *)namespaces;
- (DDXMLNode *)namespaceForPrefix:(NSString *)prefix;
- (DDXMLNode *)resolveNamespaceForName:(NSString *)name;
- (NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI;

#pragma mark - Children ---

- (void)insertChild:(DDXMLNode *)child atIndex:(NSUInteger)index;
- (void)removeChildAtIndex:(NSUInteger)index;
- (void)setChildren:(NSArray *)children;
- (void)addChild:(DDXMLNode *)child;

@end
