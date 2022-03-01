package service

import (
	"errors"

	"github.com/ybkuroki/go-webapp-sample/container"
	"github.com/ybkuroki/go-webapp-sample/model"
	"github.com/ybkuroki/go-webapp-sample/model/dto"
	"github.com/ybkuroki/go-webapp-sample/repository"
	"github.com/ybkuroki/go-webapp-sample/util"
)

// BookService is a service for managing books.
type BookService struct {
	container container.Container
}

// NewBookService is constructor.
func NewBookService(container container.Container) *BookService {
	return &BookService{container: container}
}

// FindByID returns one record matched book's id.
func (b *BookService) FindByID(id string) (*model.Book, error) {
	if !util.IsNumeric(id) {
		return nil, errors.New("failed to fetch data")
	}

	rep := b.container.GetRepository()
	book := model.Book{}
	result, err := book.FindByID(rep, util.ConvertToUint(id))
	if err != nil {
		b.container.GetLogger().GetZapLogger().Errorf(err.Error())
		return nil, err
	}
	return result, nil
}

// FindAllBooks returns the list of all books.
func (b *BookService) FindAllBooks() (*[]model.Book, error) {
	rep := b.container.GetRepository()
	book := model.Book{}
	result, err := book.FindAll(rep)
	if err != nil {
		b.container.GetLogger().GetZapLogger().Errorf(err.Error())
		return nil, err
	}
	return result, nil
}

// FindAllBooksByPage returns the page object of all books.
func (b *BookService) FindAllBooksByPage(page string, size string) (*model.Page, error) {
	rep := b.container.GetRepository()
	book := model.Book{}
	result, err := book.FindAllByPage(rep, page, size)
	if err != nil {
		b.container.GetLogger().GetZapLogger().Errorf(err.Error())
		return nil, err
	}
	return result, nil
}

// FindBooksByTitle returns the page object of books matched given book title.
func (b *BookService) FindBooksByTitle(title string, page string, size string) (*model.Page, error) {
	rep := b.container.GetRepository()
	book := model.Book{}
	result, err := book.FindByTitle(rep, title, page, size)
	if err != nil {
		b.container.GetLogger().GetZapLogger().Errorf(err.Error())
		return nil, err
	}
	return result, nil
}

// CreateBook register the given book data.
func (b *BookService) CreateBook(dto *dto.BookDto) (*model.Book, map[string]string) {
	if errors := dto.Validate(); errors != nil {
		return nil, errors
	}

	rep := b.container.GetRepository()
	var result *model.Book
	var err error

	if error := rep.Transaction(func(txrep repository.Repository) error {
		result, err = txCreateBook(txrep, dto)
		return err
	}); error != nil {
		b.container.GetLogger().GetZapLogger().Errorf(error.Error())
		return nil, map[string]string{"error": "Failed to the registration"}
	}
	return result, nil
}

func txCreateBook(txrep repository.Repository, dto *dto.BookDto) (*model.Book, error) {
	var result *model.Book
	var err error
	book := dto.Create()

	category := model.Category{}
	if book.Category, err = category.FindByID(txrep, dto.CategoryID); err != nil {
		return nil, err
	}

	format := model.Format{}
	if book.Format, err = format.FindByID(txrep, dto.FormatID); err != nil {
		return nil, err
	}

	if result, err = book.Create(txrep); err != nil {
		return nil, err
	}

	return result, nil
}

// UpdateBook updates the given book data.
func (b *BookService) UpdateBook(dto *dto.BookDto, id string) (*model.Book, map[string]string) {
	if errors := dto.Validate(); errors != nil {
		return nil, errors
	}

	rep := b.container.GetRepository()
	var result *model.Book
	var err error

	if error := rep.Transaction(func(txrep repository.Repository) error {
		result, err = txUpdateBook(txrep, dto, id)
		return err
	}); error != nil {
		b.container.GetLogger().GetZapLogger().Errorf(error.Error())
		return nil, map[string]string{"error": "Failed to the update"}
	}
	return result, nil
}

func txUpdateBook(txrep repository.Repository, dto *dto.BookDto, id string) (*model.Book, error) {
	var book, result *model.Book
	var err error

	b := model.Book{}
	if book, err = b.FindByID(txrep, util.ConvertToUint(id)); err != nil {
		return nil, err
	}

	book.Title = dto.Title
	book.Isbn = dto.Isbn
	book.CategoryID = dto.CategoryID
	book.FormatID = dto.FormatID

	category := model.Category{}
	if book.Category, err = category.FindByID(txrep, dto.CategoryID); err != nil {
		return nil, err
	}

	format := model.Format{}
	if book.Format, err = format.FindByID(txrep, dto.FormatID); err != nil {
		return nil, err
	}

	if result, err = book.Update(txrep); err != nil {
		return nil, err
	}

	return result, nil
}

// DeleteBook deletes the given book data.
func (b *BookService) DeleteBook(id string) (*model.Book, map[string]string) {
	rep := b.container.GetRepository()
	var result *model.Book
	var err error

	if error := rep.Transaction(func(txrep repository.Repository) error {
		result, err = txDeleteBook(txrep, id)
		return err
	}); error != nil {
		b.container.GetLogger().GetZapLogger().Errorf(error.Error())
		return nil, map[string]string{"error": "Failed to the delete"}
	}
	return result, nil
}

func txDeleteBook(txrep repository.Repository, id string) (*model.Book, error) {
	var book, result *model.Book
	var err error

	b := model.Book{}
	if book, err = b.FindByID(txrep, util.ConvertToUint(id)); err != nil {
		return nil, err
	}

	if result, err = book.Delete(txrep); err != nil {
		return nil, err
	}

	return result, nil
}
