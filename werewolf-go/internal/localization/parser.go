package localization

import (
	"encoding/xml"
	"io/ioutil"
	"os"
	"path/filepath"
	"log/slog"
)

type StringEntry struct {
	Key   string `xml:"key,attr"`
	Value string `xml:"value,attr"`
	IsGif bool   `xml:"isgif,attr"`
}

type LanguagePack struct {
	Name    string        `xml:"name,attr"`
	Base    string        `xml:"base,attr"`
	Variant string        `xml:"variant,attr"`
	Strings []StringEntry `xml:"string"`
	Map     map[string]StringEntry
}

type Manager struct {
	Packs map[string]*LanguagePack
}

func NewManager(langDir string) *Manager {
	mgr := &Manager{
		Packs: make(map[string]*LanguagePack),
	}

	files, err := ioutil.ReadDir(langDir)
	if err != nil {
		slog.Error("Failed to read language directory", "error", err, "dir", langDir)
		return mgr
	}

	for _, file := range files {
		if filepath.Ext(file.Name()) == ".xml" {
			pack, err := parseLanguageFile(filepath.Join(langDir, file.Name()))
			if err != nil {
				slog.Error("Failed to parse language file", "error", err, "file", file.Name())
				continue
			}
			mgr.Packs[pack.Name] = pack
			slog.Info("Loaded language pack", "name", pack.Name)
		}
	}

	return mgr
}

func parseLanguageFile(path string) (*LanguagePack, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var pack LanguagePack
	if err := xml.Unmarshal(data, &pack); err != nil {
		return nil, err
	}

	pack.Map = make(map[string]StringEntry)
	for _, s := range pack.Strings {
		pack.Map[s.Key] = s
	}

	return &pack, nil
}

func (m *Manager) GetString(lang string, key string) string {
	if pack, ok := m.Packs[lang]; ok {
		if entry, ok := pack.Map[key]; ok {
			return entry.Value
		}
		// Fallback to English if possible, or return key
		if pack.Base != "" && pack.Base != lang {
			return m.GetString(pack.Base, key)
		}
	}
	// Ultimate fallback
	if pack, ok := m.Packs["English"]; ok {
		if entry, ok := pack.Map[key]; ok {
			return entry.Value
		}
	}
	return key
}
