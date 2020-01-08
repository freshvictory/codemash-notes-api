//
//  File.swift
//  
//
//  Created by Justin Renjilian on 1/8/20.
//

import Fluent
import Vapor

struct NoteController: RouteCollection {
    func boot(router: Router) throws {
        let noteGroup = router.grouped("notes")

        noteGroup.get("", use: getAllHandler)
        
        noteGroup.get(Note.parameter, use: getNoteHandler)
        
        noteGroup.put(Note.parameter, use: updateNoteHandler)
        
        noteGroup.delete(Note.parameter, use: deleteNoteHandler)
        
        noteGroup.post("", use: createNoteHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Note]> {
        return Note.query(on: req).all()
    }
    
    func getNoteHandler(_ req: Request) throws -> Future<Note> {
        return try req.parameters.next(Note.self)
    }
    
    func createNoteHandler(_ req: Request) throws -> Future<Note> {
        return try req.content.decode(Note.self).flatMap(to: Note.self) { note in
            return note.save(on: req)
        }
    }
    
    func updateNoteHandler(_ req: Request) throws -> Future<Note> {
        return try flatMap(to: Note.self, req.parameters.next(Note.self), req.content.decode(Note.self)) { note, updatedNote in
            note.title = updatedNote.title
            note.presenter = updatedNote.presenter
            note.notes = updatedNote.notes
            note.rating = updatedNote.rating
            
            return note.save(on: req)
        }
    }
    
    func deleteNoteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Note.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
}
