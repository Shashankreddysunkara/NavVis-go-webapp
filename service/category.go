package service

import (
	"github.com/ybkuroki/go-webapp-sample/container"
	"github.com/ybkuroki/go-webapp-sample/model"
)

// CategoryService is a service for managing master data such as format and category.
type CategoryService struct {
	container container.Container
}

// NewCategoryService is constructor.
func NewCategoryService(container container.Container) *CategoryService {
	return &CategoryService{container: container}
}

// FindAllCategories returns the list of all categories.
func (m *CategoryService) FindAllCategories() *[]model.Category {
	rep := m.container.GetRepository()
	category := model.Category{}
	result, err := category.FindAll(rep)
	if err != nil {
		m.container.GetLogger().GetZapLogger().Errorf(err.Error())
		return nil
	}
	return result
}
